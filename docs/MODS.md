# 可选 Mod 管理

可选扩展统一放在 `src/mods/`。每个子目录是一个独立的 Luanti Mod，例如：

```text
src/mods/
├─ modpack.conf
├─ aurum_axe/
│  ├─ mod.conf
│  └─ init.lua
└─ local_experience/
   ├─ mod.conf
   └─ init.lua
```

它们部署到运行时的 `runtime/luanti-5.17.0-win64/games/mineclonia/mods/LOCAL_ADDONS/`，与主项目的菜单、背包、工作台等定制代码分开。

当前可选 Mod 包含 `aurum_axe`（奥金之斧）和 `local_experience`（行为记录、光照与 `/guide`）。以后新增 Mod 时，在 `src/mods/` 下创建新的子目录即可。

启用或禁用某个 Mod：

1. 关闭游戏。
2. 打开对应存档的 `world.mt`，例如 `runtime/luanti-5.17.0-win64/worlds/新的世界/world.mt`。
3. 添加或修改下面的设置：

   ```text
   load_mod_aurum_axe = true
   ```

   改为 `false` 即禁用；删除这一行或改回 `true` 即启用。
4. 重新启动游戏。

如果不需要某个 Mod，可以直接删除它的 `src/mods/<mod-name>/` 文件夹，然后运行一次：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/setup.ps1
```

部署脚本会跳过缺失的可选源文件，并清理运行时对应的生成文件；主项目的必需映射仍会照常部署。删除可选 Mod 不会删除世界存档，也不会破坏主代码逻辑。

如果某个存档里已经有该 Mod 提供的物品，禁用或删除 Mod 后这些物品可能无法显示；删除前请先清理相关物品或备份存档。
