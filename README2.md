--- 06/24/2014 ---

安装的话看Summer School那个repository的README，首先cabal update到最新版本，我一开始一直提示说cabal有新版本，即使更新了也还说有，后来发现是路径问题，新版本的cabal在 ~/Library/Haskell/bin 下，而 terminal 里调用的 cabal 是先在 /usr/bin 下找到的，只要更新下 .zshrc 下的路径就好了

同理，想要直接agda-mode setup的话也说agda-mode找不到，加 ~/Library/Haskell/bin 到 .zshrc 下就有了。不过这么个命令只是向 .emacs 中加入一两行，而且加入之后每次启动都有一个warning好烦，我后来删掉了也工作正常，所以不一定要加的

在emacs中要启用agda mode，在package list中是找不到的 (#‵′)凸，只好 agda-mode compile, 然后在 .//Library/Haskell/ghc-7.6.3/lib/Agda-2.4.0.1/share/emacs-mode/agda2.el 这个路径找到类似的 .el 文件，把 emacs-mode整个文件夹 copy到一个地方，然后在 .emacs 里

    (load-file "~/Applications/agda-emacs-mode/agda2.el")
    (load-file "~/Applications/agda-emacs-mode/agda2-mode.el")

至少目前载入了这两个就够用了

然后在emacs里 M x 就可以手动启用 agda2-mode了，如果没有自动启用的话，可能还要 M x, load-library agda2-mode 一下，不知道这一步是不是必须的。

之后按照README上的要求，M-x customize-group agda2, 这一步可以修改 Include Dirs，就像步骤里说的一样。另外，我一开始也遇到了 Emacs说：No such file or directory, agda的情况，然后在customize的设置里手动修改 program name 为绝对路径，然后就有了。


最后，ctrl c, ctrl l 载入整个 .agda 文件，然后就有代码高亮了！！

