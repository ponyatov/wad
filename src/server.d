module server;

import std.stdio;
import core.thread;

import fswatch;
import vibe.vibe;

HTTPServerSettings settings = null;
URLRouter router = null;

static this() {
    settings = new HTTPServerSettings;
    settings.port = 12345;
    settings.bindAddresses = ["127.0.0.1"];
    settings.errorPageHandler = toDelegate(&error);
    router = new URLRouter;
}

void watcher() {
    auto src = FileWatch("src/", true);
    auto views = FileWatch("views/", true);
    auto dub = FileWatch("dub.json", true);
    while (true) {
        Thread.sleep(1111.msecs);
        foreach (e; src.getEvents)
            writeln(e.path, '\t', e.type);
        foreach (e; views.getEvents)
            writeln(e.path, '\t', e.type);
        foreach (e; dub.getEvents)
            writeln(e.path, '\t', e.type);
    }
}

void main(string[] args) {
    writeln(args);
    // autorestart
    spawn(&watcher);
    // web service
    // 
    router.get("/", staticTemplate!"index.dt");
    router.get("/about/", staticTemplate!"about.dt");
    // 
    router.get("/favicon.ico", serveStaticFile("static/logo.png"));
    router.get("*", serveStaticFiles("static/"));
    // 
    listenHTTP(settings, router);
    runApplication();
}

void error(HTTPServerRequest req, HTTPServerResponse res,
        HTTPServerErrorInfo err) {
    res.render!("error.dt", req, err);
}
