# COMET HA750BL ポール固定マウント

[COMET HA750BL 製品ページ](https://www.comet-ant.co.jp/product/1316/)

**現在の設計：Rev.B — 試作用CAD・実機未検証**

3Dプリント製の一体型コの字フレームを、ポールにM6 Uボルト2本で固定するマウント。アンテナ上部（φ16mm）は樹脂貫通ガイドのみ、下部（約φ28mm）はM4熱圧入インサートを持つ着脱式の樹脂クランプで支持する。

## ファイル構成

- `cad/HA750BL_U_frame_RevB.scad` — **Rev.B 編集用の正本（OpenSCAD）**
- `cad/HA750BL_dual_clamp.scad` — 旧Rev.A参照設計
- `tools/export_revB.sh` — OpenSCADを使うSTL再生成
- `tools/validate_revB.py` — メッシュ形状・造形範囲の検査
- `VALIDATION.md` — 実施済みの確認と未検証事項
- `CHANGELOG.md` — 設計変更履歴

## 生成済みSTL・組立画像

- [Rev.B フレーム（印刷用）](stl/HA750BL_RevB_frame_print.stl)
- [Rev.B 下部押さえ（印刷用）](stl/HA750BL_RevB_lower_cap_print.stl)
- [Rev.B フレーム（設計座標）](stl/HA750BL_RevB_frame.stl)
- [Rev.B 下部押さえ（設計座標）](stl/HA750BL_RevB_lower_cap.stl)
- [Rev.B 組立画像](images/HA750BL_RevB_assembly.png)
- [旧Rev.AのSTL一覧](stl/)
- [旧Rev.Aの設計説明](docs/README_RevA.md)

GitHub ActionsによりCAD更新時にSTL・画像を生成・検証してコミットする。ワークフロー：[export-geometry.yml](.github/workflows/export-geometry.yml)。

ローカルでの再生成：OpenSCADとPython（trimesh、networkx、numpy）が必要。ルートディレクトリから `bash tools/export_revB.sh`、`python tools/validate_revB.py` を実行。Windowsの場合はOpenSCADのGUIで `part="frame_print"` / `part="lower_cap_print"` を選んでSTLを出力できる。

## Rev.B 初期パラメータ（mm）

| 項目 | 設定 | 注意 |
|---|---:|---|
| 取付ポール外径 | 32 | 暫定。実測要 |
| 上部エレメント径 | 16 | 提供された寸法 |
| 上部貫通ガイド穴 | 17.2 | 金属なし、締付なし |
| 下部固定箇所の外径 | 約28 | 実測要 |
| 下部クランプ穴 | 28.3 | 成形公差・クリアランス確認 |
| Uボルト | M6 × 2本 | 25A足長型・脚ピッチ約41mmが仮候補 |
| 下部固定 | M4ボルト2本 + 熱圧入ナット2個 | インサート穴φ5.7mm暫定 |
| 上下保持中心間隔 | 172 | 暫定。実測要 |

Bambu Lab A1、PETG造形を想定。利用前にポール径、保持箇所の上下間隔、干渉、印刷嵌合、ねじ・ナットの寸法を確認する。

### 注意

アンテナの全長・風荷重に対し、PETG製マウント単独の屋外常設安全性は未評価。独立した落下防止措置と機械強度の検証が必要。下部φ28mmがコネクターの回転する締付ナットなら、そこを把持しない。放熱フィン・エアダクトを塞がず、設置前後のSWRを確認すること。

## 設計の出典

- メーカー資料： https://www.comet-ant.co.jp/product/1316/
- 直径φ16mm／約φ28mm：製作者による提供寸法（2026-10-21）
- 樹脂3Dプリント用の未検証試作設計。製造承認・強度保証は行っていない。
