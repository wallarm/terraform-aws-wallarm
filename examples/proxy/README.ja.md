					# AWS VPC内のプロキシとしてWallarmをデプロイする

この例は、[Terraformモジュール](https://registry.terraform.io/modules/wallarm/wallarm/aws/)を使用して、既存のAWS Virtual Private Cloud（VPC）にインラインプロキシとしてWallarmをデプロイする方法を説明します。

Wallarmのプロキシソリューションは、WAAPとAPIセキュリティ機能を持つ高度なHTTPトラフィックルータとして機能する追加のネットワーク層を提供します。

[プロキシ高度ソリューション](https://github.com/wallarm/terraform-aws-wallarm/tree/main/examples/advanced)を試すことで、ソリューションの柔軟性を実際に確認できます。

## 主要な特性

* Wallarmは同期モードでトラフィックを処理し、Wallarmの機能を制約せず、即時の脅威の緩和を可能にします（`preset=proxy`）。
* Wallarmソリューションは、他の層から独立して制御できる別のネットワーク層としてデプロイされ、ほぼあらゆるネットワーク構造位置に層を配置できます。推奨される位置は、インターネット向けロードバランサの背後です。

## ソリューションのアーキテクチャ

![Wallarm proxy scheme](https://github.com/wallarm/terraform-aws-wallarm/blob/main/images/wallarm-as-proxy.png?raw=true)

Wallarmのプロキシソリューションの例には、以下のコンポーネントが含まれています：

* WallarmノードインスタンスにトラフィックをルーティングするInternet-facing Application Load Balancer。
* トラフィックを分析し、任意のリクエストをさらにプロキシするWallarmノードインスタンス。対応する要素は、スキーマ上のA、B、CのEC2インスタンスです。

    この例では、説明された動作を引き起こす監視モードでWallarmノードを実行します。Wallarmノードは、悪意のあるリクエストのブロックと、正当なリクエストだけをさらに転送することを目的とした他のモードでも動作できます。Wallarmノードモードの詳細については、[弊社のドキュメンテーション](https://docs.wallarm.com/admin-en/configure-wallarm-mode/)をご覧ください。
* Wallarmノードがリクエストをプロキシするサービス。サービスは任意の型のものが可能です。例えば：

    * VPCエンドポイントを介してVPCに接続したAWS API Gatewayアプリケーション（対応するWallarm Terraformデプロイメントは、[API Gatewayの例](https://github.com/wallarm/terraform-aws-wallarm/tree/main/examples/apigateway)でカバーされています）。
    * AWS S3
    * EKSクラスター内で実行されるEKSノード（このケースのために、内部ロードバランサーまたはNodePort Serviceの設定が推奨されています）
    * その他のバックエンドサービス

    Wallarmノードはデフォルトで`https://httpbin.org`にトラフィックを転送します。この例の起動中には、AWS Virtual Private Cloud（VPC）から利用可能な任意の他のサービスドメインやパスを指定して、トラフィックをプロキシすることができます。

    `https_redirect_code = 302` モジュール設定オプションを使用すると、AWS ALBによるHTTPのリクエストを安全にHTTPSにリダイレクトできます。

リストされたコンポーネント（プロキシされたサーバーを除く）は、提供された`wallarm`例モジュールによってデプロイされます。

## コードのコンポーネント

この例には、以下のコードのコンポーネントが含まれています：

* `main.tf`：プロキシソリューションとしてデプロイされる`wallarm`モジュールの主な設定。設定はAWS ALBとWallarmインスタンスを生成します。
* `ssl.tf`：ドメイン名`variable_name`で指定されたドメインに対して新たなAWS Certificate Manager（ACM）を自動的に発行し、それをAWS ALBにバインドするSSL / TLSオフロード設定。

    この機能を無効にするには、`ssl.tf`と`dns.tf`ファイルを削除するかコメントアウトし、さらに`wallarm`モジュール定義中の`lb_ssl_enabled`、`lb_certificate_arn`、`https_redirect_code`、`depends_on`オプションをコメントアウトしてください。この機能が無効になると、HTTPポート（80）だけを使用できます。
* `dns.tf`：AWS ALB用にDNSレコードをプロビジョニングするAWS Route 53設定。

    フィーチャを無効にするには、上記の注意事項に従ってください。

## 要件

* Terraform 1.0.5以上が[ローカルにインストール](https://learn.hashicorp.com/tutorials/terraform/install-cli)されていること
* [EU Cloud](https://my.wallarm.com/)または[US Cloud](https://us1.my.wallarm.com/)のWallarmコンソールで**管理者**役割のアカウントにアクセスできること
* EUのWallarm Cloudと共同作業している場合は`https://api.wallarm.com`に、USのWallarm Cloudと共同作業している場合は`https://us1.api.wallarm.com`にアクセスすること。ファイアウォールによってアクセスがブロックされていないことを確認してください
* SSLとDNS機能が有効の例を実行するには、[Route 53ホスティングゾーン](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html)を設定してください

## 例のWallarm AWSプロキシソリューションの実行

1. [EU Cloud](https://my.wallarm.com/nodes)または[US Cloud](https://us1.my.wallarm.com/nodes)のWallarmコンソールでサインアップします。
1. Wallarmコンソール→**ノード**を開き、**Wallarmノード**タイプのノードを作成します。
1. 生成されたノードトークンをコピーします。
1. 例のコードが含まれるリポジトリをマシンにクローンします：

    ```
    git clone https://github.com/wallarm/terraform-aws-wallarm.git
    ```
1. クローンしたリポジトリの`examples/proxy/variables.tf`ファイルの`default`オプションで変数の値を設定し、変更を保存します。
1. `examples/proxy/main.tf`→`proxy_pass`でプロキシサーバのプロトコルとアドレスを設定します。

    初期設定では、Wallarmは`https://httpbin.org`にトラフィックをプロキシします。初期値があなたのニーズに合致する場合は、そのままにしておいてください。
1. `examples/proxy`ディレクトリから次のコマンドを実行してスタックをデプロイします：

    ```
    terraform init
    terraform apply
    ```

デプロイされた環境を削除するには、次のコマンドを使用します：

```
terraform destroy
```

## トラブルシューティング

### Wallarmがインスタンスの作成と終了を繰り返す

提供されるAWS Auto Scalingグループの設定は、サービスの最高の信頼性とスムーズさに焦点を当てています。AWS Auto Scalingグループのイニシャライズ中にEC2インスタンスを何度も作成し、終了するのは、ヘルスチェックが失敗したためかもしれません。

この問題を解決するには、以下の設定を確認し、修正してください：

* WallarmノードトークンがWallarm Console UIからコピーされた有効な値であること
* NGINX設定が有効であること
* NGINX設定に指定されたドメイン名が正常に解決されていること（例えば`proxy_pass`の値）

**究極的な対策** 上記の設定が有効であるにもかかわらず問題が解決しない場合は、Auto Scalingグループの設定で手動でELBのヘルスチェックを無効にして問題の原因を見つけることができます。これにより、サービス設定が無効であってもインスタンスはアクティブのまま保たれ、インスタンスは再起動しません。これにより、ログを詳細に調査し、サービスをデバッグする時間が増え、問題が数分で解決する可能性があります。

## 参照資料

* [AWS ACM証明書](https://docs.aws.amazon.com/acm/latest/userguide/gs.html)
* [公開とプライベートサブネット（NAT）を持つAWS VPC](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)