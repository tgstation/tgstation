python -m pip install --upgrade pip
pip install -r ./tools/translate/requirements.txt

git fetch origin
git config --local user.email "action@github.com"
git config --local user.name "ss220bot"

git checkout -b translate_tmp
git reset --hard origin/master

echo Moving old translation...
git checkout translate -- ./tools/translate/ss220replace.json
git commit -m "Move old translation"

echo Generating new translation...
git cherry-pick -n translate
git reset .
python ./tools/translate/converter.py
git add ./tools/translate/ss220replace.json
git commit -m "Generate translation file"
git restore .

echo Applying result...
./tools/translate/ss220_replacer_linux
git commit -m "Apply translation"

git push -f origin translate_tmp:translate
