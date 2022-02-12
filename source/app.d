import std.stdio;
import arsd.minigui;

void main()
{
	auto window = new MainWindow();

	auto hello = new TextLabel("Hello, world!", TextAlignment.Center, window);
	auto button = new Button("Close", window);
	button.addEventListener((scope ClickEvent ev) { window.close(); });

	window.loop();
}
