# COMET HA750BL ポール固定マウント

[メーカー公式のHA750BL製品情報](https://www.comet-ant.co.jp/product/1316/)

**現在の設計：Rev.C（2026-10-23）— 実物組立の失敗を受けた修正版／CAD検証済み、再装着未検証**

Rev.Bでは上下の保持孔中心間隔172mmが短すぎ、給電部の放熱フィンが支柱と干渉した。Rev.Cは上下を独立L型保持部に分割し、各部をM6 Uボルト1本ずつポールに装着、中央の補強プレートで接続してコの字にする。

- **φ16mm側：** 金属ねじなしのφ17.2mm樹脂貫通ガイド
- **約φ28mm側：** Rev.Bと同寸法の分割クランプ／M4熱圧入インサート2個（下部押さえは再利用可）
- **中央：** M5熱圧入インサート4個とM5ねじ4本の交換式補強プレート
- **造形：** Bambu Lab A1／PETG。上・下保持部を先に実機へ独立して合わせ、中心間距離を測って補強プレートのみ再出力する

## Rev.C主なファイル

- [編集用OpenSCAD正本](cad/HA750BL_U_frame_RevC.scad)
- [下部L型本体STL](stl/HA750BL_RevC_lower_frame_print.stl)
- [上部L型本体STL](stl/HA750BL_RevC_upper_frame_print.stl)
- [下部押さえSTL](stl/HA750BL_RevC_lower_cap_print.stl)
- [補強プレートSTL](stl/HA750BL_RevC_bridge_print.stl)
- [Rev.C 組立画像](images/HA750BL_RevC_assembly.png)
- [寸法・試作手順・未検証事項](docs/RevC_physical_fit.md)
- [Rev.C再生成スクリプト](tools/export_revC.sh) と [メッシュ検証](tools/validate_revC.py)

初期設定：ポール径φ32mm（**仮寸法**）、保持中心間隔280mm（**仮寸法**）。補強プレートの現在の設計対応範囲は230～340mm。実寸が判明するまで280mmを正解と見なさない。

## 旧版とGit管理

- [Rev.B CAD](cad/HA750BL_U_frame_RevB.scad) / [Rev.B資料](VALIDATION.md)
- [Rev.A CAD](cad/HA750BL_dual_clamp.scad) / [Rev.A資料](docs/README_RevA.md)
- [変更履歴](CHANGELOG.md)
- [自動ビルド・STL検証](.github/workflows/export-geometry.yml)

**安全上の注意：** 下部のφ28mm部分が回転するコネクターナットなら、締め付けに使用しない。フィンと底面エアダクトを塞がず、PETGの屋外風荷重・紫外線・クリープ、Uボルト強度、二次落下防止、設置前後のSWRを実機確認する。CAD形状検査だけでは屋外常設の安全性を保証しない。
