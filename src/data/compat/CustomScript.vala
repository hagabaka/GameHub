/*
This file is part of GameHub.
Copyright (C) 2018 Anatoliy Kashkin

GameHub is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

GameHub is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GameHub.  If not, see <https://www.gnu.org/licenses/>.
*/

using GameHub.Utils;

using GameHub.Data.Sources.Steam;

namespace GameHub.Data.Compat
{
	public class CustomScript: CompatTool
	{
		public const string SCRIPT = "customscript.sh";
		private const string SCRIPT_TEMPLATE = """#!/bin/bash
GH_EXECUTABLE="$1"
GH_INSTALL_DIR="$2"
GH_GAME_ID="$3"
GH_GAME_ID_FULL="$4"
GH_GAME_NAME="$5"
GH_GAME_NAME_ESCAPED="$6"

""";

		construct
		{
			id = @"customscript";
			name = @"Custom script";
			icon = "application-x-executable-symbolic";
			installed = true;

			actions = {
				new CompatTool.Action(_("Edit script"), _("Edit custom script"), edit_script)
			};
		}

		public override bool can_run(Game game)
		{
			return true;
		}

		public override async void run(Game game)
		{
			var gh_dir = FSUtils.mkdir(game.install_dir.get_path(), COMPAT_DATA_DIR);
			var script = gh_dir.get_child(SCRIPT);
			if(script.query_exists())
			{
				Utils.run({"chmod", "+x", script.get_path()});
				var executable_path = game.executable != null ? game.executable.get_path() : "null";
				string[] cmd = { script.get_path(), executable_path, game.id, game.full_id, game.name, game.escaped_name };
				yield Utils.run_thread(cmd, game.install_dir.get_path());
			}
			else
			{
				edit_script(game);
			}
		}

		public void edit_script(Game game)
		{
			var gh_dir = FSUtils.mkdir(game.install_dir.get_path(), COMPAT_DATA_DIR);
			var script = gh_dir.get_child(SCRIPT);
			if(!script.query_exists())
			{
				try
				{
					FileUtils.set_contents(script.get_path(), SCRIPT_TEMPLATE, SCRIPT_TEMPLATE.length);
				}
				catch(Error e)
				{
					warning("[CustomScript.edit_script] %s", e.message);
				}
			}
			Utils.run({"chmod", "+x", script.get_path()});
			Utils.open_uri(script.get_uri());
		}
	}
}