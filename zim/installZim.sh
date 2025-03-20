#!/bin/bash
apt install zsh
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

sed -i '/zmodule completion/d' ~/.zimrc
sed -i '/zmodule fzf/d' ~/.zimrc
sed -i '/zmodule Aloxaf/fzf-tab/d' ~/.zimrc
sed -i '/zmodule romkatv/powerlevel10k/d' ~/.zimrc
cat << EOF >>~/.zimrc
zmodule fzf
zmodule Aloxaf/fzf-tab
zmodule romkatv/powerlevel10k
EOF

wget --show-progress -cqO ~/.p10k.zsh https://raw.githubusercontent.com/jacyl4/dev-env-conf/main/zim/p10k.zsh

zimfw install
