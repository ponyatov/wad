module index;

import vibe.vibe;

class Index {
    void index() {
        render!"index.dt";
    }

    // /find_employee
    void getFindEmployee() {
        response.writeBody("This is getFindEmployee");
    }
}
