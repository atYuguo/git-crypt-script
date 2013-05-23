#Git加密脚本
这个软件用于实现对远程版本库的完整加密。主要方法来源于：

>[Transparent Git Encryption][1] : gist.github.com/shadowhand/873637

我做了一些改进，并且实现一定的自动化，更多信息请继续阅读。

##LICENSE
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
	
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.


##基本过程
通过这个软件配置本地版本库后，当进行 `git add` 动作时， `git` 自动调用 `filter` 里的 `clean_filter_openssl` 将文件内容输出到 ‘clean_filter_openssl’ 脚本中。 `clean_filter_openssl` 脚本逐行读入这些输出，在行末添加 `\r` 然后加密连接起来的完整字符串。当然最后提交和 `push` 的都是加密文件。

执行 `checkout` 时， `git` 自动调用 `filter` 里的 `smudge_filter_openssl` 解密后，自动替换 `\r` 为 `\n` 得到明文。

##加密算法
如果你读过[Transparent Git Encryption][1]，可能为上面提到的复杂过程感到困惑，实际情况还要复杂些。这一节来了解一下细节。

在[Transparent Git Encryption][1]里，作者使用了 `aes-256-ecb` 算法，并且使用了固定的密钥和“盐”（salt）。这是为了保障每个文件每次加密的结果都相同，因为如果采用其他算法以及随机“盐”，那么即便是相同的文件每次加密的结果也不相同，虽然不影响 `git diff` 的结果，但是却不能正常使用 `git status`。按照作者的说法，如果采用非确定的加密方法，即使什么都不改变， `git status` 也会给出文件修改的结果。

但是根据我在网上查到的资料 `aes-256-ecb` 本身就不够安全，为了达到应有的可靠性，只建议加密小于一个区块长度的明文，并且每一个密钥只建议加密相同的区块一次。而且作者还采用了固定的“盐”，就更加不安全。

为了能同时兼顾安全性和 `git` 的功能，我采用的是 `aes-256-cbc` 算法以及固定密钥和随机“盐”，不过，我将每个文件的 `sha1` 码和“盐”以下列形式存储在 `~/.git_secure/<your-reponame>/hashandsalt` 文件中：

><pre><code>sha1@salt</code></pre>

每次 `git add` 时，先判断文件的 `sha1` 有没有改变，如果没有改变，就采用过去的“盐”，加上固定密钥，加密的结果和原来是一样的；如果文件改变了，就产生新的随机“盐”用于加密，并将新的 `sha1@salt` 存储在 `hashandsalt` 文件中。

这样，只要有 `hashandsalt` 文件，就不存在[Transparent Git Encryption][1]里所说的采用非确定加密算法的问题。如果没有 `hashandsalt` 文件，只要知道密钥也可以解密，但当两个不同的本地库和远程库同步时会存在问题。

根据我在网上看到的资料，公开 `hashandsalt` 文件的内容似乎不影响安全性，但实际情况我并不清楚。

这种做法带来一个问题： `git add` 时，文件内容以标准输入的形式传入 `clean_filter_openssl` 中，但我只知道如何一行一行的读入这些内容，所以没有办法读取“回车”，只能采用在连接两行时中间添加一个 `\r` ，然后再解密时替换成回车，有的时候这个操作会使文件发生改变(多出一些空行)， `git diff` 会给出差别，而且这样一来，不能操作二进制文件。如果谁有解决这个问题的好方法，麻烦告诉我:)

##使用方法
运行 `Init.sh` 按照提示输入版本库路径和你想使用的密码，就可以自动配置好。之后只需要像通常一样的使用 `git`。要注意对历史的加密。

你的密码明文的保存在

><pre><code>~/.git_secure/<your-reponame>/

里的三个 `*_filter_openssl` 文件里，要注意保护这些文件。

这个工具目前稳定性未知，请做好备份工作。


[1]:https://gist.github.com/shadowhand/873637 "Transparent Git Encryption"
