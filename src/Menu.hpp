#ifndef MENU_HPP
#define MENU_HPP

#include <string>
#include <vector>
#include <map>

namespace icprog {

struct MenuItem {
    int id;
    std::string label;
    std::string shortcut;
    std::string description;
    bool enabled;
};

class Menu {
public:
    Menu();
    ~Menu();

    void addMenuItem(const std::string& menu, const MenuItem& item);
    void run();
    void exit();

    static Menu& instance();

private:
    struct Impl;
    Impl* impl_;
};

} // namespace icprog

#endif