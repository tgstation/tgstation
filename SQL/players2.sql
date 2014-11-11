
-- Table: players
CREATE TABLE players ( 
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,
    player_ckey         TEXT    NOT NULL,
    player_slot         INTEGER NOT NULL,
    ooc_notes           TEXT,
    real_name           TEXT,
    random_name         INTEGER,
    gender              TEXT,
    age                 INTEGER,
    species             TEXT,
    language            TEXT,
    flavor_text         TEXT,
    med_record          TEXT,
    sec_record          TEXT,
    gen_record          TEXT,
    player_alt_titles   TEXT,
    be_special          TEXT,
    disabilities        INTEGER,
    nanotrasen_relation TEXT,
    UNIQUE ( player_ckey, player_slot ) 
);


-- Table: body
CREATE TABLE body ( 
    ID                INTEGER PRIMARY KEY AUTOINCREMENT,
    player_ckey       TEXT    NOT NULL,
    player_slot       INTEGER NOT NULL,
    hair_red          INTEGER,
    hair_green        INTEGER,
    hair_blue         INTEGER,
    facial_red        INTEGER,
    facial_green      INTEGER,
    facial_blue       INTEGER,
    skin_tone         INTEGER,
    hair_style_name   TEXT,
    facial_style_name TEXT,
    eyes_red          INTEGER,
    eyes_green        INTEGER,
    eyes_blue         INTEGER,
    underwear         INTEGER,
    backbag           INTEGER,
    b_type            TEXT,
    FOREIGN KEY ( player_ckey, player_slot ) REFERENCES players ( player_ckey, player_slot ) ON DELETE CASCADE,
    UNIQUE ( player_ckey, player_slot ) 
);


-- Table: jobs
CREATE TABLE jobs ( 
    ID                INTEGER PRIMARY KEY AUTOINCREMENT,
    player_ckey       TEXT    NOT NULL,
    player_slot       INTEGER NOT NULL,
    alternate_option  INTEGER,
    job_civilian_high INTEGER,
    job_civilian_med  INTEGER,
    job_civilian_low  INTEGER,
    job_medsci_high   INTEGER,
    job_medsci_med    INTEGER,
    job_medsci_low    INTEGER,
    job_engsec_high   INTEGER,
    job_engsec_med    INTEGER,
    job_engsec_low    INTEGER,
    FOREIGN KEY ( player_ckey, player_slot ) REFERENCES players ( player_ckey, player_slot ) ON DELETE CASCADE,
    UNIQUE ( player_ckey, player_slot ) 
);


-- Table: limbs
CREATE TABLE limbs ( 
    ID          INTEGER PRIMARY KEY AUTOINCREMENT,
    player_ckey TEXT    NOT NULL,
    player_slot INTEGER NOT NULL,
    l_arm       TEXT,
    r_arm       TEXT,
    l_leg       TEXT,
    r_leg       TEXT,
    l_foot      TEXT,
    r_foot      TEXT,
    l_hand      TEXT,
    r_hand      TEXT,
    heart       TEXT,
    eyes        TEXT,
    FOREIGN KEY ( player_ckey, player_slot ) REFERENCES players ( player_ckey, player_slot ) ON DELETE CASCADE,
    UNIQUE ( player_ckey, player_slot ) 
);


-- Table: client
CREATE TABLE client ( 
    ID             INTEGER NOT NULL
                           PRIMARY KEY AUTOINCREMENT,
    ckey           INTEGER UNIQUE,
    ooc_color      TEXT,
    lastchangelog  TEXT,
    UI_style       TEXT,
    default_slot   INTEGER,
    toggles        INTEGER,
    UI_style_color TEXT,
    UI_style_alpha INTEGER,
    randomslot     INTEGER,
    volume         INTEGER,
    special        INTEGER,
    warns          INTEGER,
    warnbans       INTEGER 
);


-- Table: client_roles
CREATE TABLE client_roles ( 
    ckey       TEXT    UNIQUE,
    slot       INTEGER,
    role       TEXT    NOT NULL,
    preference INTEGER NOT NULL,
    PRIMARY KEY ( ckey, slot, role ),
    FOREIGN KEY ( ckey, slot ) REFERENCES players ( player_ckey, player_slot ) ON DELETE CASCADE 
);

