# gittemplate

git template is a collection of hook scripts.

## Use

 + for clone: clone this repo and apply for your repo
```shell
git clone git@github.com:Your/Repo.git --template=/path/to/gittemplate
```

 + for init local repo
```shell
mkdir -p /path/to/your-repo
git -C /path/to/your-repo --template=/path/to/gittemplate
```

 + update hooks
```shell
rm -rf /path/to/your-repo/.git/hooks
cp -Rf /path/to/gittemplate/hooks /path/to/your-repo/.git
```
