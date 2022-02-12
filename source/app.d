import std.stdio;
import arsd.minigui;
import arsd.jsvar : var;
import arsd.script : interpret;
import std.algorithm;
import std.file;
import std.utf : byChar;

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
			writeln("Loaded " ~ ds.name ~ " into memory");
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
			writeln("Loaded " ~ ds.name ~ " into memory");
			auto data = readText(ds.name);
			interpret(data, globals);
		}
	}

}

void main()
{
	loadScripts();
	auto window = new MainWindow("Makercord", 1280, 720);

	@scriptable auto vers = new TextLabel("v0.1", TextAlignment.Right, window);

	@scriptable auto tabs = new TabWidget(window);

	//auto prjs = new TabWidgetPage("Projects", tabs);

	@scriptable struct Menu
	{
		@menu("&File")
		{
			@accelerator("CTRL+S")
			void Save()
			{
				window.statusBar.parts[0].content = "I have saved successfully!";
			}

			@menu("&File")
			{
			}

			@separator
			void Exit()
			{
				window.statusBar.parts[0].content = "Bye!";
				window.close();

			}
		}
		@menu("&Help")
		{
			void About()
			{
				auto msg = new MessageBox("Written in D, made by Lily");
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
	}

	@scriptable Menu menu;

	window.setMenuAndToolbarFromAnnotatedCode(menu);

	window.loop();
}
