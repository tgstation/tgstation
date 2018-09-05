param(
    $game_path
)

Write-Host "Deploying tgstation compilation..."

cd $game_path

mkdir build

#.github is a little special cause of the prefix
mv .github build/.github

mv * build   #thank god it's that easy 

&"build/tools/deploy.sh" $game_path $game_path/build

Remove-Item build -Recurse
