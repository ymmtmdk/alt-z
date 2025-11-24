# Command-Not-Found Fallback Feature

## Summary

コマンドが見つからない場合に自動的に `az` にフォールバックしてディレクトリジャンプを試みる機能を実装しました。

## Implementation Status

### ✅ Fish Shell - **完全に動作**

Fish shellでは `fish_command_not_found` イベントハンドラを使用して、この機能が完全に動作します。

**実装場所**: `az.fish`

**使用例**:
```fish
$ myproject  # 存在しないコマンド
az: jumping to /home/user/projects/myproject
$ pwd
/home/user/projects/myproject
```

**テスト**: `test_az_fish_fallback.fish` - すべてのテストがPASS ✓

### ❌ Bash/Zsh - **技術的制限により不可**

Bash と Zsh では、`command_not_found_handle` / `command_not_found_handler` がサブシェルで実行されるため、`cd` コマンドが親シェルに影響を与えません。

**制限の理由**:
- Bashの `command_not_found_handle` はサブシェルコンテキストで実行される
- Zshの `command_not_found_handler` も同様の制限がある
- サブシェル内での `cd` は親シェルのカレントディレクトリを変更できない

**代替案**:
1. 手動で `az <directory-name>` を使用する（これは正常に動作します）
2. Fish shellを使用する（完全に動作します）

## Technical Details

### Fish Shell Implementation

```fish
function fish_command_not_found
    set -l cmd $argv[1]
    set -l target ($_ALT_Z_CMD query -e $cmd 2>/dev/null)
    
    if test $ret -eq 0; and test -n "$target"; and test -d "$target"
        echo "az: jumping to $target" >&2
        cd "$target"
    else
        echo "fish: Unknown command: $cmd" >&2
        return 127
    end
end
```

### Why Bash/Zsh Don't Work

Bashの `command_not_found_handle` は以下のように動作します：

```bash
# これはサブシェルで実行される
command_not_found_handle() {
    cd /some/path  # ← 親シェルには影響しない
}
```

この動作はBash/Zshの設計上の仕様であり、回避できません。

## Recommendation

**コマンド未検出時の自動フォールバック機能を使いたい場合は、Fish shellの使用を推奨します。**

Bash/Zshユーザーは、従来通り `az <directory-name>` を手動で入力することで、同じディレクトリジャンプ機能を利用できます。
