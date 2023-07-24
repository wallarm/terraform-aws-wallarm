# Wallarm OOBのNGINX、Envoy、および同様のミラーリングをTerraformモジュールを使用して展開する

この記事では、[Wallarm Terraformモジュール](https://registry.terraform.io/modules/wallarm/wallarm/aws/)を使用して、AWSにWallarmをOut-of-Bandソリューションとしてデプロイする**例**を示します。 NGINX、Envoy、Istio、および/またはTraefikがトラフィックミラーリングを提供することが期待されています。

## 主な特性

* Wallarmは現在のトラフィックフローに影響を与えずに非同期モード（`preset=mirror`）でトラフィックを処理するため、このアプローチは最も安全なものです。
* Wallarmソリューションは他のレイヤーから独立して制御できる別のネットワークレイヤーとしてデプロイされ、このレイヤーをほぼ任意のネットワーク構造位置に配置することができます。推奨する位置はプライベートネットワークになります。

## ソリューションアーキテクチャ

![Wallarm for mirrored traffic](https://github.com/wallarm/terraform-aws-wallarm/blob/main/images/wallarm-for-mirrored-traffic.png?raw=true)

この例のWallarmソリューションには以下のコンポーネントが含まれています：

* WallarmノードインスタンスにトラフィックをルーティングするInternet-facingロードバランサ。ロードバランサーは既にデプロイされていることが想定されており、 `wallarm`モジュールはこのリソースを作成しません。
* ロードバランサからトラフィックを提供し、HTTPリクエストを内部ALBエンドポイントとバックエンドサービスにミラーリングする任意のWebまたはプロキシサーバー（例：NGINX、Envoy）。トラフィックミラーリングに使用されるコンポーネントは既にデプロイされていることが想定されており、 `wallarm`モジュールはこのリソースを作成しません。
* WebまたはプロキシサーバーからのミラーリングされたHTTPSリクエストを受け入れ、それらをWallarmノードインスタンスに転送する内部ALB。
* 内部ALBからのリクエストを分析し、悪意のあるトラフィックデータをWallarmクラウドに送信するWallarmノード。

    この例では、説明された動作を導くモニタリングモードでWallarmノードを実行します。[モード](https://docs.wallarm.com/admin-en/configure-wallarm-mode/)を別の値に切り替えると、ノードは[OOB](https://docs.wallarm.com/installation/oob/overview/#advantages-and-limitations)アプローチが攻撃ブロックを許可しないため、トラフィックを監視し続けます。

最後の2つのコンポーネントは提供された `wallarm`例モジュールによってデプロイされます。

## コードコンポーネント

この例には以下のコードコンポーネントが含まれています：

* `main.tf`：ミラーソリューションとしてデプロイされる `wallarm`モジュールの主要な設定。この設定は内部のAWS ALBとWallarmインスタンスを生成します。

## HTTPリクエストミラーリングの設定

トラフィックミラーリングは、多くのWebおよびプロキシサーバーが提供する機能です。[リンク](https://docs.wallarm.com/installation/oob/web-server-mirroring/overview/#examples-of-web-server-configuration-for-traffic-mirroring)は、いくつかのサーバーでトラフィックミラーリングを設定する方法のドキュメンテーションを提供します。

## 制限事項

説明された例のソリューションが最も機能的なOut-of-Band Wallarmソリューションであるにもかかわらず、非同期アプローチに固有の制限がいくつかあります：

* トラフィック解析が実際のトラフィックフローに関係なく進行するため、Wallarmノードは即座に悪意のあるリクエストをブロックしません。
* このソリューションには追加のコンポーネントが必要であり、それはトラフィックミラーリングまたは同様のツールを提供するWebまたはプロキシサーバー（例：NGINX、Envoy、Istio、Traefik、カスタムKongモジュールなど）です。

## 例のWallarmミラーソリューションの実行

1. [EU Cloud](https://my.wallarm.com/nodes)または[US Cloud](https://us1.my.wallarm.com/nodes)でWallarmコンソールにサインアップします。
1. Wallarm Console→ **Nodes**を開き、**Wallarm node**タイプのノードを作成します。
1. 生成したノードトークンをコピーします。
1. 例のコードを含むリポジトリをマシンにクローンします：

    ```
    git clone https://github.com/wallarm/terraform-aws-wallarm.git
    ```
1. クローンしたリポジトリの `examples/mirror/variables.tf`ファイルの `default`オプションで変数値を設定し、変更を保存します。
1. `examples/mirror`ディレクトリから次のコマンドを実行してスタックをデプロイします：

    ```
    terraform init
    terraform apply
    ```

デプロイされた環境を削除するには、次のコマンドを使用します：

```
terraform destroy
```

## 参考資料

* [パブリックとプライベートのサブネットを持つAWS VPC（NAT）](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html)
