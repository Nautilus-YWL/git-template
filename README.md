# git-template

git template is a collection of hook scripts.

## Usage

 + for clone: clone this repo and apply for your repo
```shell
git clone git@github.com:Your/Repo.git --template=/path/to/git-template
```

 + for init local repo
```shell
mkdir -p /path/to/your-repo
git -C /path/to/your-repo init --template=/path/to/git-template
```

 + update hooks
```shell
rm -rf /path/to/your-repo/.git/hooks
cp -Rf /path/to/git-template/hooks /path/to/your-repo/.git
```
