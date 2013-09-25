using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using Sanford.Multimedia;
using Sanford.Multimedia.Midi;

namespace midi2piano
{
    public partial class Form1 : Form
    {
        [STAThread]
        public static void Main()
        {
            Application.EnableVisualStyles();
            Application.Run(new Form1());
        }

        public Form1()
        {
            InitializeComponent();
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Close();
        }

        struct PNote
        {
            public float Length;
            public string Note;

            public PNote(float length, string note)
            {
                Length = length;
                Note = note;
            }

            public static readonly PNote Default = new PNote(0, "");
        }

        private void importMIDIToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (importDlg.ShowDialog(this)
                == System.Windows.Forms.DialogResult.Cancel)
                return;

            List<PNote> notes = new List<PNote>();
            PNote curNote = PNote.Default;
            float tempo = 1;
            float timeSig = 4f;

            // first, we pull midi data
            Sequence s = new Sequence(importDlg.FileName);

            // quickly see if there's a piano track first
            // and get the tempo as well
            int piano = -1;
            for (int it = 0; it < s.Count; it++)
            {
                Track t = s[it];
                foreach (MidiEvent me in t.Iterator())
                {
                    switch (me.MidiMessage.MessageType)
                    {
                        case MessageType.Channel:
                            {
                                ChannelMessage m = (ChannelMessage)me.MidiMessage;
                                if (m.Command == ChannelCommand.ProgramChange)
                                    if ((GeneralMidiInstrument)m.Data1 == GeneralMidiInstrument.AcousticGrandPiano)
                                    {
                                        piano = it;
                                    }
                            }
                            break;
                        case MessageType.Meta:
                            {
                                MetaMessage m = (MetaMessage)me.MidiMessage;
                                if (m.MetaType == MetaType.Tempo)
                                    tempo = (new TempoChangeBuilder(m)).Tempo;
                                else if (m.MetaType == MetaType.TimeSignature)
                                    timeSig = new TimeSignatureBuilder(m).Denominator;
                            }
                            break;
                    }
                    if (piano >= 0)
                        break;
                }
                if (piano >= 0)
                    break;
            }

            // didn't find one, so just try 0th track anyway
            if (piano == -1)
                piano = 0;

            // now, pull all notes (and tempo)
            // and make sure it's a channel that has content
            for (int it = piano; it < s.Count; it++)
            {
                Track t = s[it];

                int delta = 0;
                foreach (MidiEvent me in t.Iterator())
                {
                    delta += me.DeltaTicks;

                    switch (me.MidiMessage.MessageType)
                    {
                        case MessageType.Channel:
                            {
                                ChannelMessage m = (ChannelMessage)me.MidiMessage;
                                switch (m.Command)
                                {
                                    case ChannelCommand.NoteOn:
                                        if (curNote.Note != "")
                                        {
                                            curNote.Length = delta / 1000F;
                                            delta = 0;
                                            notes.Add(curNote);
                                        }

                                        curNote.Note = note2Piano(m.Data1);
                                        break;
                                }
                            }
                            break;
                        case MessageType.Meta:
                            {
                                MetaMessage m = (MetaMessage)me.MidiMessage;
                                if (m.MetaType == MetaType.Tempo)
                                    tempo = (new TempoChangeBuilder(m)).Tempo;
                            }
                            break;
                    }
                }

                // make sure we get last note
                if (curNote.Note != "")
                {
                    curNote.Length = delta / 1000F;
                    notes.Add(curNote);
                }

                // we found a track with content!
                if (notes.Count > 0)
                    break;
            }

            // compress redundant accidentals/octaves
            char[] notemods = new char[7];
            int[] noteocts = new int[7];
            for (int i = 0; i < 7; i++)
            {
                notemods[i] = 'n';
                noteocts[i] = 3;
            }
            for (int i = 0; i < notes.Count; i++)
            {
                string noteStr = notes[i].Note;
                int cur_note = noteStr[0] - 0x41;
                char mod = noteStr[1];
                int oct = int.Parse(noteStr.Substring(2));

                noteStr = noteStr.Substring(0, 1);
                if (mod != notemods[cur_note])
                {
                    noteStr += new string(mod, 1);
                    notemods[cur_note] = mod;
                }
                if (oct != noteocts[cur_note])
                {
                    noteStr += oct.ToString();
                    noteocts[cur_note] = oct;
                }

                notes[i] = new PNote(notes[i].Length, noteStr);
            }

            // now, we find what the "beat" length should be,
            // by counting numbers of times for each length, and finding statistical mode
            Dictionary<float, int> scores = new Dictionary<float, int>();
            foreach (PNote n in notes)
            {
                if (n.Length != 0)
                    if (scores.Keys.Contains(n.Length))
                        scores[n.Length]++;
                    else
                        scores.Add(n.Length, 1);
            }
            float winner = 1;
            int score = 0;
            foreach (KeyValuePair<float, int> kv in scores)
            {
                if (kv.Value > score)
                {
                    winner = kv.Key;
                    score = kv.Value;
                }
            }
            // realign all of them to match beat length
            for (int i = 0; i < notes.Count; i++)
            {
                notes[i] = new PNote(notes[i].Length / winner, notes[i].Note);
            }

            // compress chords down
            for (int i = 0; i < notes.Count; i++)
            {
                if (notes[i].Length == 0 && i < notes.Count - 1)
                {
                    notes[i + 1] = new PNote(notes[i + 1].Length, notes[i].Note + "-" + notes[i + 1].Note);
                    notes.RemoveAt(i);
                    i--;
                }
            }

            // add in time
            for (int i = 0; i < notes.Count; i++)
            {
                float len = notes[i].Length;
                notes[i] = new PNote(len, notes[i].Note + (len != 1 ? "/" + (1 / len).ToString("0.##") : ""));
            }

            // what is the bpm, anyway?
            int rpm = (int)(28800000 / tempo / winner); // 60 * 1,000,000 * .48  the .48 is because note lengths for some reason midi makes the beat note be .48 long

            // now, output!
            string line = "";
            string output = "";
            int lineCount = 1;
            foreach (PNote n in notes)
            {
                if (line.Length + n.Note.Length + 1 > 51)
                {
                    output += line.Substring(0, line.Length - 1) + "\r\n";
                    line = "";
                    if (lineCount == 50)
                        break;
                    lineCount++;
                }
                line += n.Note + ",";
            }
            if (line.Length > 0)
                output += line.Substring(0, line.Length - 1);
            OutputTxt.Text = "BPM: " + rpm.ToString() + "\r\n" + output;
            OutputTxt.SelectAll();
        }

        public enum NoteNames
        {
            C = 0,
            D = 2,
            E = 4,
            F = 5,
            G = 7,
            A = 9,
            B = 11
        }

        string note2Piano(int n)
        {
            string name, arg, octave;
            name = Enum.GetName(typeof(NoteNames), (NoteNames)(n % 12));
            if (name == null)
            {
                name = Enum.GetName(typeof(NoteNames), (NoteNames)((n + 1) % 12));
                arg = "b";
            }
            else
            {
                arg = "n";
            }
            octave = (n / 12 - 1).ToString();

            return name + arg + octave;
        }

        private void copyToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OutputTxt.SelectAll();
            OutputTxt.Copy();
        }

        private void halpToolStripMenuItem_Click(object sender, EventArgs e)
        {
            MessageBox.Show(this,
                "This program prefers MIDIs that have a single track, otherwise it picks the first piano track it finds, else the first track. Songs with odd tempos may have their BPM's calculated wrong.",
                "Halp", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
    }
}
