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

void watcher(int iN) {
    auto watcher = FileWatch("src/", true);
    int n=iN;
    while (true) {
        writeln(thisTid,n++);
        Thread.sleep(1111.msecs);
    }
}

void main(string[] args) {
    writeln(args);
    // autorestart
    foreach (i; 0..10)
    spawn(&watcher,i*100);
    // Thread.start(watcher);
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
