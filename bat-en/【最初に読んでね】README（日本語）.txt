Zundamon Speech Builder（ずんだもんスピーチビルダー）
=======================================================

このフォルダを任意の場所に配置してバッチファイルを実行することにより「Zundamon Speech（ずんだもんスピーチ）」を起動するための環境構築を自動で行い、最後に起動用のバッチファイルを出力します。

仮想環境を構築してから実行するので他のPythonプロジェクトなどへの影響が出ないようにしています（依存関係などは仮想環境内にインストールして構築されます）。

バッチファイルの実行前に事前準備が必要なので以下を必ずお読みください。


〇 手順

【共通】

各種ツールなどのインストールが必要なため、方法がわからない場合は次の動画を参考にしてください。
https://youtu.be/cWBAWCUg9s4


【CPU版】※ NVidiaのGPUは必要ありません

1 このフォルダを任意の場所に置く

 ※ フォルダ名およびフォルダまでのルート名（パス）はすべて半角英数字にしてください【例 C:\Users\Documents\zundamonspeech など】


2 Python 3.9.13 をインストールする（3.9.13で動作することが確認されています）
https://www.python.org/downloads/release/python-3913/

※ インストールするときは「ADD Python 3.9 to PATH」に必ずチェックを入れる

※ Pythonは互換性が脆弱なため、他のバージョンをインストールすると動作しない可能性があります


3 Gitをインストールする
https://git-scm.com/

4 Visual Studio Build Toolsをインストールする
https://visualstudio.microsoft.com/ja/visual-cpp-build-tools/

※ 「C++によるデスクトップ開発」にチェックを入れてインストールする


5 CMakeをインストールする
https://cmake.org/download/


6「zundamonspeech_builder_cpu_v〇〇.bat」を実行する（「gpu」とまちがえないように注意！）

7 最初に確認のメッセージが出てくるので、準備ができていたら任意のキーを押す

8 環境構築がスタートするのでしばらくお待ちください。

※ 警告メッセージが出てきたときは内容を確認し「Y」または「N」を入力して実行してください。


9 完了するとフォルダ内に「launch_zundamon.bat」が自動作成されるのでそれを実行する

10 ブラウザ上に操作画面が表示される（はず...）

  ※ 初回は起動するまでに時間がかかります



［GPU版］

1～5 CPU版と同じ

6 CUDA12.1 をインストールする
https://developer.nvidia.com/cuda-12-1-0-download-archive

※ Pythonよりは互換性がありますがバージョン違いにより動作しない可能性があります


7 「zundamonspeech_builder_gpu_v〇〇.bat」を実行する（「cpu」とまちがえないように注意！）

8 最初に確認のメッセージが出てくるので、準備ができていたら任意のキーを押す

9 環境構築がスタートするのでしばらくお待ちください。

※ 警告メッセージが出てきたときは「Y」または「N」を入力して実行してください。

10 完了するとフォルダ内に「launch_zundamon.bat」が自動作成されるのでそれを実行する

11 ブラウザ上に操作画面が表示される（はず...）

  ※ 初回は起動するまでに時間がかかります



【Zundamon Speechの使い方】

以下の説明でもわからないときは動画を参考にしてください。
https://youtu.be/cWBAWCUg9s4

・Step1 Reference Audio File

  AIが参考にするための音声ファイルをアップロードします。【Zundamon-Speech-WebUI】-【reference】フォルダ内に音声ファイルがあるのでドラッグアンドドロップしましょう。

・Step2 Reference Text

  音声ファイルに対応するテキストを入力します。上記フォルダ内にテキストファイルがあるのでコピペできます。

・Step3 Target Text

  ずんだもんに喋ってほしいセリフを入力します。「日本語に変換したい場合は日本語」のように変換したい言語で入力します。

・Step4 Language Selection

  Step1にアップロードした音声と変換したい音声の言語を選択します。セリフ内に複数の言語が混ざっている場合は「～Mixed」を選択します。

あとは「Generate Speech」をクリックすれば生成スタートです。

※ CPU版の場合は生成スピードが遅いので気長に待ちましょう。


できあがった音声は「Download Generated Audio」ボタンを押すとWAVファイルとして保存できます。



〇 動作テスト環境

【CPU版（ノートPC）】

・CPU：AMD Ryzen7 Mobile 2700U
・メモリ：16GB（DDR4）
・GPU：AMD Radeon・RX Vega 10 Graphics

※ 6年前のノートPCですが問題なく動きました。


【GPU版（デスクトップPC）】

・CPU：Intel Core i9-14900F
・メモリ：64GB（DDR5）
・GPU：NVidia GeForce RTX4090


【zundamon-speech-webui】
https://github.com/zunzun999/zundamon-speech-webui?tab=readme-ov-file

【音源利用規約（ずんずんPJ）】
https://zunko.jp/con_ongen_kiyaku.html



2025/3/7 Ver1.0公開

========================================
作成者：YuuPro（ゆうぷろ）
https://www.youtube.com/c/yuupro
https://x.com/YuuPro_2022