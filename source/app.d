import std.stdio : writeln;
import arsd.minigui;
import arsd.jsvar : var;
import arsd.script : interpret;
import std.algorithm;
import std.file : write, dirEntries, mkdir, exists, SpanMode, readText;
import core.thread.osthread;
import core.time;
import std.utf : byChar;

/// p
enum ProjectType
{
	js,
	py
}

/// new Project
/// Params:
///   name = the name of the project
///   projtype = the project type, currently only 2 but more to come
void newProj(string name, ProjectType projtype)
{

	auto creation = new MainWindow("Makercord Project creation", 400, 500);

	auto tkn = new TextLabel("Token", TextAlignment.Center, creation);
	auto token = new TextEdit(creation);
	auto prfx = new TextLabel("Prefix", TextAlignment.Center, creation);
	auto prefix = new TextEdit(creation);
	auto sex = new TextLabel("Test guild (Slash commands and such)", TextAlignment.Center, creation); // funny
	auto test = new TextEdit(creation);
	auto button = new Button("Confirm", creation);
	button.addEventListener((scope ClickEvent ev) { creation.close(); });

	creation.loop();

	if (projtype == ProjectType.js)
	{

		name.mkdir();

		write(name ~ "/bot.js", "test");
	}
	else if (projtype == ProjectType.py)
	{
		name.mkdir();
		write(name ~ "/bot.py", "import disnake
from disnake.ext import commands
bot = commands.Bot(command_prefix=\""
				~ prefix.content ~ "\", test_guilds=["
				~ test.content ~ "])

bot.run(\""
				~ token.content ~ "\")
		");
	}

}
/// open a project
/// Params:
///   path = path to the project.bot
///   parent = parent widget
void openProj(string path, Widget parent)
{
	auto proj = new TabWidgetPage(path, parent);
}

/// Scrpt loader (rewrite soon)
void loadScripts()
{

	var globals = var.emptyObject;

	if (!"scripts".exists)
	{
		"scripts".mkdir();
		auto scriptFiles = dirEntries("scripts/", SpanMode.depth)
			.filter!(f => f.name.endsWith(".ds"));

		foreach (ds; scriptFiles)
		{
			globals.name = ds.name;
			globals.write = (string txt) { writeln(txt); };
			globals.popup = (string msg) { auto msg_popup = new MessageBox(msg); };
			auto data = readText(ds.name);
			interpret(data, globals);
		}
	}
	else
	{
		auto scriptFiles = dirEntries("scripts/", SpanMode.depth)
			.filter!(f => f.name.endsWith(".ds"));

		foreach (ds; scriptFiles)
		{
			globals.name = ds.name;
			globals.write = (string txt) { writeln(txt); };
			globals.popup = (string msg) { auto msg_popup = new MessageBox(msg); };
			auto data = readText(ds.name);
			interpret(data, globals);
		}
	}

}

void main()
{

	auto vers_txt = "v0.1";
	loadScripts();
	auto window = new MainWindow("Makercord", 1280, 720);

	@scriptable auto vers = new TextLabel(vers_txt, TextAlignment.Right, window);

	@scriptable auto tabs = new TabWidget(window);

	@scriptable struct Menu
	{
		static string sugFile = "Folder";
		static string sugProj = "ProjectName";
		@menu("&File")
		{

			@accelerator("CTRL+P")
			void Create_PY(FileName!sugProj filename)
			{
				newProj(filename, ProjectType.py);
				window.statusBar.parts[0].content = "Created!";
			}

			@accelerator("CTRL+J")
			void Create_JS(FileName!sugProj filename)
			{
				newProj(filename, ProjectType.js);
				window.statusBar.parts[0].content = "Created!";
			}

			@separator

			@accelerator("CTRL+O")
			void Open(FileName!sugFile filename)
			{
				openProj(filename, tabs);
				window.statusBar.parts[0].content = "Opened!";
			}

			@separator
			void Exit()
			{
				window.statusBar.parts[0].content = "Bye!";
				Thread.sleep(dur!("msecs")(256));
				window.close();

			}
		}
		@menu("&Scripts")
		{
			@accelerator("CTRL+R")
			void Reload_All()
			{
				loadScripts();
				auto msg = new MessageBox("Done.");
			}
		}
		@menu("&Help")
		{
			void About()
			{
				auto msg = new MessageBox("Written in D, made by Lily");
			}
		}
	}

	@scriptable Menu menu;

	window.setMenuAndToolbarFromAnnotatedCode(menu);

	window.loop();
}
