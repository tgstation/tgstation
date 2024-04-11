python -m pip install --upgrade pip
pip install -r ./tools/translate/requirements.txt

git fetch origin
git config --local user.email "action@github.com"
git config --local user.name "ss220bot"

git checkout -b translate_tmp
git reset --hard origin/master

git checkout translate -- ./tools/translate/ss220replace.json

./tools/translate/ss220_replacer_linux
git commit -m "Apply translation"

git push -f origin translate_tmp:translate
