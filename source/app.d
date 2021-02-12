import vibe.vibe;
import std.stdio;
import std.process;
import termcolor;

@path("/api/")
interface APIRoot {
	@safe
    string get();
}

void showHome(HTTPServerRequest req, HTTPServerResponse res)
{
	serveStaticFiles("/index.html");
}


class API : APIRoot {
    override string get() { return "Hello, World"; }
}

void main()
{
	auto router = new URLRouter;
	router.registerRestInterface(new API());

	// Serve all Static Files from the /public folder
	router
		.get("/", &showHome)
		.get("*", serveStaticFiles("public"));

	// GET http://127.0.0.1:8080/api/ and 'Hello, World' will be replied
	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["127.0.0.1"];

	listenHTTP(settings, router);

	auto svelteBuild = executeShell("cd svelte && npm run build");
	if (svelteBuild.status == 0) {
		writeln(svelteBuild.output);
		writeln(C.blueDark.fg, "[Svelte Built] Listening for requests on http://", settings.bindAddresses[0], ":", settings.port, resetColor);
		runApplication();
	}
	if (svelteBuild.status != 0) writeln("Svelte build failed:\n", svelteBuild.output);

}
