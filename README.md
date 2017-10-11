vim-hlparen
===========

カーソル下にある括弧の対応をハイライトするプラグインです

概要
----

Demo
----

Requirement
-----------

- Vim 8.0

使用法
-----

オプション
----

### `g:hlparen_insmode_trigger`

挿入モード `i` `a` (および置換モード `R`) において、ハイライトをするタイミングを指定する。

- `'close_only'` : 閉じ括弧の両方の入力時のみに対応する括弧をハイライトする
- `'both'` : 開き括弧・閉じ括弧の両方の入力時に対応する括弧をハイライトする (デフォルト)

```vim
let g:hlparen_insmode_trigger = 'both'
```

### `g:hlparen_highlight_delay`

カーソルが括弧に移動後、ハイライトするまでの遅延時間(ミリ秒)

- `150` (デフォルト)

```vim
let g:hlparen_highlight_delay = 1000
```

### `g:hlparen_highlight_style`

括弧のハイライト時のスタイル

- `parenthesis` : マッチする括弧のみをハイライト (デフォルト)
- `expression` : マッチした括弧で囲まれた部分もハイライト

```vim
let g:hlparen_highlight_style = 'parenthesis'
```

### `HlParenMatch`

ハイライト時に使用されるハイライトグループ

```vim
highlight! link HlParenMatch MatchParen
```

Install
-------

使用時にはデフォルトの matchparen プラグインを無効化しておいてください。

```vim
let g:loaded_matchparen = 1
```

License
-------

[MIT License](./LICENSE)

Author
------

sgur <sgurrr@gmail.com>
