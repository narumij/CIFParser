# CIFParse

Objective-C CIF parser framework.

## Memo

完成にはほど遠いのですが、とりあえず動きます。

Sample1はmac Appの形態になっていますが、1wnsをパースしてログに吐き出すだけのもの。

Sample2は3j3yを読み込んでリボンで表示します。手持ちのマックで30~40secほどでパースできますが、その後リボンの生成とSceneKitにかなり待たされます。パースは一通りファイルを舐めてはいますが、部分的にしかロードしていないので数値はあくまでずるいほうの参考値です。

試行錯誤の痕跡だらけで汚いのですが力尽きたので一旦公開することにしました。

## License

See the [LICENSE](https://github.com/narumij/CIFParser/LICENSE)
file in the repository.

## Built With

* [flex](https://www.gnu.org/software/flex/) - The Fast Lexical Analyzer used

## Acknowledgments

同梱している1wnsと3j3yは[RCSB PDB](https://www.rcsb.org)よりお借りしています。とても助かりました。感謝しています。
