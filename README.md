#Git加密脚本
这个软件用于实现对远程版本库的完整加密。主要方法来源于：

>[Transparent Git Encryption][1] : gist.github.com/shadowhand/873637

我做了一些改进，并且实现一定的自动化，更多信息请继续阅读。

##LICENSE
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
	
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

##依赖

gcc

openssl

openssl-devel

xxd

dd

base64


##基本过程
通过这个软件配置本地版本库后，当进行 `git add` 动作时， `git` 自动调用 `filter` 里的 `clean_filter_openssl` 将文件内容输出到 `clean_filter_openssl` 脚本中。 `clean_filter_openssl` 调用 `writeTemp.o` 将标准输入写入

><pre><code>~/.git_secure/\<your-reponame\>/temp

文件，然后将这个文件的加密结果作为标准输出。当然最后提交和 `push` 的都是加密文件。执行 `checkout` 时， `git` 自动调用 `filter` 里的 `smudge_filter_openssl` 解密。

##加密算法
在 [Transparent Git Encryption][1] 里，作者使用了 `aes-256-ecb` 算法，并且使用了固定的密钥和“盐”（salt）。这是为了保障每个文件每次加密的结果都相同，因为如果采用其他算法以及随机“盐”，那么即便是相同的文件每次加密的结果也不相同，虽然不影响 `git diff` 的结果，但是却不能正常使用 `git status`。按照作者的说法，如果采用非确定的加密方法，即使什么都不改变， `git status` 也会给出文件修改的结果。

但是根据我在网上查到的资料 `aes-256-ecb` 本身就不够安全，为了达到应有的可靠性，只建议加密小于一个区块长度的明文，并且每一个密钥只建议加密相同的区块一次。而且作者还采用了固定的“盐”，就更加不安全。

为了能同时兼顾安全性和 `git` 的功能，我采用的是 `aes-256-cbc` 算法、固定密钥以及 `openssl` 按照默认方法生成的盐。**不同于这个脚本的旧版本，现在这个脚本完全使用 `openssl aes-256-cbc` 加密的默认设置，不需要独立的生成随机盐，也不需要在代码库中引入 `hashandsalt` 文件，所以安全性和便利性都完全得到了保障！**

这是因为注意到了 `openssl aes-256-cbc` 加密时，所用的盐保存在加密后文件的前16位的后8位上。所以现在的执行过程是：

1. 解密时保存原来的 salt 和解密后明文的 hash 到 `~/.git_secure/\<your-reponame\>/hashandsalt` 文件中，这个文件每次会自动生成，无需专门保存或随版本库携带。

2. 加密时根据 `hashandsalt` 文件判断明文的 hash 有没有改变。如果 hash 没有改变，就提取过去的 salt, 然后用下述命令加密：

```bash
openssl enc -aes-256-cbc -S $originalSalt -k $PASS_FIXED -base64 -in $TEMP_PATH
```

如果 hash 发生了改变，则用下面的命令

```bash
openssl enc -aes-256-cbc -k $PASS_FIXED -base64 -in $TEMP_PATH
```

这样一来，文件没有改变的情况下，加密的结果也不会改变，避免了 [Transparent Git Encryption][1] 里所说的采用非确定加密算法的问题。同时没有使用固定的盐，而且采用的加密算法也足够强健，安全得到了保障。

##使用方法
初次加密，运行 `Init.sh` 按照提示输入版本库路径和你想使用的密码，就可以自动配置好，之后只需要像通常一样的使用 `git`，要注意对历史的加密。对于克隆的加密版本库同样运行 `Init.sh` 并输入路径，脚本会根据已经有的信息自动配置好。

PS: 如果 clone 的版本库进行上述操作后没有解密，请手动

```bash
git reset --hard
```

##注意事项
你的密码明文的保存在

><pre><code>~/.git_secure/\<your-reponame\>/</pre></code>

里的三个 `*_filter_openssl` 文件里，要注意保护这些文件。

这个工具目前稳定性未知，请做好备份工作。

##有待改进

因为 `writeTemp.c` 在处理二进制文件是总是出问题，所以目前加密采用 `base64` 编码，但估计若能直接操作二进制文件会改善效率。如果哪位大神有兴趣，还望不吝赐教。


[1]:https://gist.github.com/shadowhand/873637 "Transparent Git Encryption"
