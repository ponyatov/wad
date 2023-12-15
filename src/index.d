module index;

import vibe.vibe;

class Index {
    void index() {
        render!"index.dt";
    }

    void getFindEmployee() {
        response.writeBody("This is getFindEmployee");
    }
}
