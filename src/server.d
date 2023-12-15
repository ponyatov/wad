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

shared bool stop = false;

void watcher() {
    auto src = FileWatch("src/", true);
    auto views = FileWatch("views/", true);
    auto dub = FileWatch("dub.json", true);
    while (!stop) {
        Thread.sleep(1111.msecs);
        foreach (e; src.getEvents ~ views.getEvents ~ dub.getEvents) {
            stop = true;
            writeln(e.path, '\t', e.type);
        }
    }
}

void main(string[] args) {
    writeln(args);
    // 
    router.get("/", staticTemplate!"index.dt");
    router.get("/about/", staticTemplate!"about.dt");
    // 
    router.get("/favicon.ico", serveStaticFile("static/logo.png"));
    router.get("*", serveStaticFiles("static/"));
    // 
    auto listener = listenHTTP(settings, router);
    scope (exit) listener.stopListening();
    auto watcherTid = spawn(&watcher);
    runApplication();
    // if (stop) {
    //     listener.stopListening();
    //     vibe.core.core.exitEventLoop();
    // }
}

void error(HTTPServerRequest req, HTTPServerResponse res,
        HTTPServerErrorInfo err) {
    res.render!("error.dt", req, err);
}
