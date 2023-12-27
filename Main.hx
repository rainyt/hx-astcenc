class Main {
	static function main() {
		var isWindow = Sys.systemName() == "Windows";
		Sys.exit(Sys.command("./tools/Tools" + (isWindow ? ".exe" : ""), Sys.args()));
	}
}
