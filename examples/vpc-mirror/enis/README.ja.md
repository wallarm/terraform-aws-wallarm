# VPC-mirrorの例のための付録：ENIの取得

**情報** これはTerraformモジュール、またはモジュール例の設定ではありません。このドキュメントは[AWS ENI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html)の取得方法と、[AWS VPCによりミラーリングされたトラフィックを分析するWallarmの例](https://github.com/wallarm/terraform-aws-wallarm/tree/main/examples/vpc-mirror)の運用についての詳細を提供します。

このフォルダには、ENI IDをさまざまな方法で取得する以下の設定例が含まれています:

* `by_asg.tf`：オートスケーリング・グループ内のすべてのインスタンスからすべてのENIを取得するため。
* `by_eks.tf`：EKSノード・グループ内のすべてのインスタンスからすべてのENIを取得するため。
* `by_elb.tf`：クラシックELBのためのすべてのENIを取得するため。ALBおよびNLBはトラフィックミラーリングをサポートしません。
* `by_tags.tf`：AWSタグですべてのENIを取得するため。AWSはENIに対して自動的にタグを設定しませんが、手動で設定することができます。

**注記** リソースの手動および自動作成または破壊は、ENI IDが変更され、その結果、ミラーリングセッションが前のIDから切り離される可能性があります。たとえば、ASGをスケーリングアップまたはダウンすると、EC2インスタンスが破壊され、その後にEC2のENIが作成または破壊されます。このTerraform例は、AWS APIからENIを収集する方法を示していますが、説明されたケースでトラフィックミラーリングが続くことを保証しません。

`../interfaces.tf`ファイルで必要なENI設定を指定することができます。