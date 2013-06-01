import std.stdio;
import std.process;
import std.path;
import std.conv;
import std.string;
import std.math;
import std.algorithm;
import std.array;
import std.range;


struct Info
{
	string percent;
	string funcName;
}

string getCommand(string[] args)
{
	auto result = args[1];
	if (args.length > 1)
		foreach(a; args[2..args.length])
			result = result~" "~a;
	return result;
}

void writeRectangle(
	ulong x,
	ulong y,
	ulong round,
	ulong width,
	ulong height,
	ulong r,
	ulong g,
	ulong b,
	ref File f)
{
	f.writeln("<rect x = \"" ~ to!string(x) ~
		"\" y =  \"" ~ to!string(y) ~
		"\" rx = \"" ~ to!string(round) ~
		"\" ry = \"" ~ to!string(round) ~
		"\" width = \"" ~ to!string(width) ~
		"\" height = \"" ~ to!string(height) ~
		"\" style = \"fill:rgb(" ~
			to!string(r) ~ ", " ~
			to!string(g) ~ ", " ~
			to!string(b) ~ ")\"/>");
}

void writeText(
	ulong x,
	ulong y,
	string font,
	ulong fontSize,
	string text,
	ref File f)
{
	f.writeln("<text x = \"" ~ to!string(x) ~
		"\" y = \"" ~ to!string(y) ~
		"\" font-family = \"" ~ font ~
		"\" font-size = \"" ~ to!string(fontSize) ~
		"\" fill = \"black" ~
		"\" >" ~ text ~ "</text>");
}

void generateSVG()
{
	File f = File("perf.txt", "r");
	scope(exit) f.close;

	File f2 = File("perf.svg", "w");
	f2.writeln("<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" height=\"3000\">");
	scope (exit) f2.write("</svg>");

	f.readln; //skip the first line

	Info[] infos;
	string junk;

	while (!f.eof)
		f.readf(" %s %s %s %s\n ", &infos[++infos.length - 1].percent
			, &junk, &junk, &infos[infos.length - 1].funcName);
		writeln(infos[infos.length - 1].funcName);

	auto len = (Info i) => i.funcName.length;
	ulong width = 9 * min(140, reduce!max(map!len(infos)));

	for(ulong i = 0; i < infos.length; i++)
	{
		ulong color = cast(ulong)(pow(to!float(infos[i].percent[0..$-1])/100, 0.2) * 255);
		ulong y = (i + 1) * 30;

		infos[i].funcName = infos[i].funcName.replace("<", "!(").replace(">", ")");
		infos[i].funcName = infos[i].funcName[3..$].replace("&", " ref");
		if (infos[i].funcName.length > 150)
			infos[i].funcName = infos[i].funcName[0..150]~"...";

		writeRectangle(30, y, 3, width, 25, color, 255 - color, 0, f2);
		writeText(35, y + 15, "monospace", 12, infos[i].funcName, f2);
		writeText(width - 15, y + 15, "monospace", 12, infos[i].percent, f2);

	}
}


int main(string args[])
{
	auto pid = spawnShell("perf record "~getCommand(args)~" > /dev/null 2>&1 &&
		perf report | cat | grep "~baseName(args[1])~" > perf.txt");
	wait(pid);
	generateSVG();
	pid = spawnShell("eog --fullscreen perf.svg &");
	wait(pid);
	return 0;
}