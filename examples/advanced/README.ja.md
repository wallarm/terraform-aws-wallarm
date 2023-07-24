# Wallarm AWS Terraform モジュールのデプロイ例: プロキシ高度ソリューション

この例では、Wallarmを高度な設定を備えたインラインプロキシとして、既存のAWSバーチャルプライベートクラウド（VPC）にTerraformモジュールを使用してデプロイする方法を説明します。[シンプルなプロキシデプロイメント](https://github.com/wallarm/terraform-aws-wallarm/tree/main/examples/proxy)によく似ていますが、頻繁に使用される高度な設定オプションが示されています。

この例を始めるのが難しい場合は、まず[シンプルなプロキシ例](https://github.com/wallarm/terraform-aws-wallarm/tree/main/examples/proxy)をご覧ください。

Wallarmプロキシ高度ソリューション(シンプルなプロキシも含む)は、WAFおよびAPIセキュリティ機能を備えた高度なHTTPトラフィックルータとしての追加的な機能ネットワークレイヤーを提供します。

## 主な特性

プロキシ高度ソリューションはシンプルなものと以下のように異なります：

* このソリューションはロードバランサー（`lb_enabled=false`）を作成しませんが、それでも既存のロードバランサーにアタッチできるターゲットグループを作成します。

    これにより、同期的なトラフィック処理アプローチにシームレスに切り替えることができます。
* NGINXとWallarmの設定は、標準変数だけでなく、`global_snippet`、`http_snippet`、`server_snippet`のNGINXスニペットでも指定されます。
* Wallarmノード初期化スクリプト（cloud-init）が完了すると、カスタムの`post-cloud-init.sh`スクリプトがカスタムHTMLインデックスページを`/var/www/mysite/index.html`インスタンスディレクトリに配置します。
* デプロイされたスタックは、AWS S3への読み取り専用アクセスを可能にする追加のAWS IAMポリシーに関連付けられています。

    この例を"そのまま"使用する場合、提供されたアクセスは必要ありません。それにもかかわらず、`post-cloud-init.sh`ファイルには、通常特別なアクセスを必要とするAWS S3からのファイルのリクエストの非アクティブな例が含まれています。`post-cloud-init.sh`ファイルからS3コードをアクティブにする場合、`extra_policies`変数内でAWS S3アクセスIAMポリシーを指定する必要があります。
* このソリューションでは、追加の内部ネットワークポート7777からWallarmインスタンスへのインバウンド接続が可能です。これは、`extra_ports`変数と`http_snippet.conf`で設定されます。

    ポート7777を`0.0.0.0/0`に許可するためには、追加で`extra_public_ports`変数を使用することもできます（任意）。
* Wallarmノードは、ブロッキングモードでトラフィックを処理します。

## ソリューションのアーキテクチャ

![Wallarmプロキシスキーム](https://github.com/wallarm/terraform-aws-wallarm/blob/main/images/wallarm-as-proxy.png?raw=true)

例のWallarmプロキシ高度ソリューションには以下のコンポーネントが含まれています：

* ロードバランサーがないAuto Scalingグループにアタッチされたターゲットグループ。
* トラフィックを分析し、悪意のあるリクエストをブロックし、正当なリクエストをさらにプロキシするWallarmノードインスタンス。

    この例では、記述された動作を駆動するブロッキングモードでWallarmノードを実行します。Wallarmノードは、悪意のあるリクエストのブロッキングを含まないトラフィックモニタリングのみを目指した他のモードでも動作できます。Wallarmノードモードの詳細については、[弊社のドキュメンテーション](https://docs.wallarm.com/admin-en/configure-wallarm-mode/)をご利用ください。
* Wallarmノードはトラフィックを`https://httpbin.org`にプロキシします。

    この例の実行中に、AWSバーチャルプライベートクラウド（VPC）から利用可能な他のサービスドメインやパスをトラフィックをプロキシするために指定することができます。

すべてのリストされたコンポーネント（プロキシされたサーバを除く）は、提供された`wallarm`例モジュールによってデプロイされます。

## コードコンポーネント

この例には以下のコードコンポーネントが含まれています：

* `main.tf`：`wallarm`モジュールの主要設定は、プロキシ高度ソリューションとしてデプロイされます。
* `global_snippet.conf`：`global_snippet`変数を使用してNGINXグローバル設定に追加されるカスタムNGINX設定の例。マウントされた設定には`load_module`、`stream`、`mail`、`env`などのディレクティブを含めることができます。
* `http_snippet.conf`：`http_snippet`変数を使用して`http` NGINXコンテキストに追加されるカスタムNGINX設定。マウントされた設定には`map`や`server`などのディレクティブを含めることができます。
* `server_snippet.conf`：`server_snippet`変数を使用して`server` NGINXコンテキストに追加されるカスタムNGINX設定。マウントされた設定は、`if`のNGINXロジックと必要な`location`設定を導入できます。

    このスニペット設定はポート80にのみ適用されます。他のポートを開くには、`http_snippet`で対応する`server`ディレクティブを指定します。

    `server_snippet.conf`ファイルでは、より複雑な設定例も見つけることができます。
* `post-cloud-init.sh`：カスタムHTMLインデックスページを`/var/www/mysite/index.html`インスタンスディレクトリに配置するカスタムスクリプト。このスクリプトは、Wallarmノードの初期化（cloud-initスクリプト）の後に実行されます。

    `post-cloud-init.sh`ファイルでは、AWS S3のコンテンツをインスタンスディレクトリに配置する例のコマンドも見つけることができます。このオプションを使用する場合は、`extra_policies`変数内でS3アクセスポリシーを指定することを忘れないでください。

## Wallarm AWSプロキシソリューションの実行

1. [EUクラウド](https://my.wallarm.com/nodes)または[USクラウド](https://us1.my.wallarm.com/nodes)でWallarm Consoleにサインアップします。
1. Wallarm Console→ **ノード**を開き、**Wallarmノード**タイプのノードを作成します。
1. 生成されたノードトークンをコピーします。
1. 例のコードを含むリポジトリをあなたのマシンにクローンします：

    ```
    git clone https://github.com/wallarm/terraform-aws-wallarm.git
    ```
1. クローンされたリポジトリの`examples/advanced/variables.tf`ファイル内の`default`オプションで変数値を設定し、変更を保存します。
1. `examples/advanced/main.tf`→ `proxy_pass`内でプロキシされるサーバのプロトコルとアドレスを設定します。

    デフォルトでは、Wallarmはトラフィックを`https://httpbin.org`にプロキシします。デフォルト値があなたのニーズに合っている場合、そのままにしておいてください。
1. `examples/advanced`ディレクトリから以下のコマンドを実行してスタックをデプロイします：

    ```
    terraform init
    terraform apply
    ```

デプロイされた環境を削除するには、以下のコマンドを使用します：

```
terraform destroy
```

## 参考文献

* [AWSのロードバランサーをAuto Scalingグループにアタッチする](https://docs.aws.amazon.com/autoscaling/ec2/userguide/attach-load-balancer-asg.html)
* [公開および非公開のサブネット（NAT）を備えたAWS VPC](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)
* [Wallarmドキュメンテーション](https://docs.wallarm.com)