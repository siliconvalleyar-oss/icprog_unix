#include "Menu.hpp"
#include <ncurses.h>
#include <string>
#include <map>
#include <vector>
#include <functional>

namespace icprog {

struct Menu::Impl {
    std::map<std::string, std::vector<MenuItem>> menus;
    bool running = false;
    int maxY, maxX;
    
    std::string currentDevice = "PIC16F84";
    std::string currentPort = "/dev/ttyUSB0";
    int currentBuffer = 0;
    std::string bufferStatus[5] = {"Empty", "Empty", "Empty", "Empty", "Empty"};
};

Menu::Menu() : impl_(new Impl()) {}
Menu::~Menu() { delete impl_; }

Menu& Menu::instance() {
    static Menu m;
    return m;
}

void Menu::addMenuItem(const std::string& menu, const MenuItem& item) {
    impl_->menus[menu].push_back(item);
}

void Menu::exit() {
    impl_->running = false;
}

void Menu::run() {
    initscr();
    cbreak();
    noecho();
    keypad(stdscr, TRUE);
    curs_set(0);
    
    getmaxyx(stdscr, impl_->maxY, impl_->maxX);
    
    // Create main menu items
    std::vector<std::string> menuNames = {
        "&Archivo", "&Comando", "&Ajustes", "&Buffer", "&Hardware", "&Ayuda"
    };
    
    impl_->running = true;
    int selectedMenu = 0;
    int selectedItem = 0;
    
    while (impl_->running) {
        clear();
        
        // Draw title
        attron(A_BOLD | A_REVERSE);
        mvhline(0, 0, ACS_HLINE, impl_->maxX);
        mvaddstr(1, 2, "IC-Prog - PIC Microcontroller Programmer");
        attroff(A_BOLD | A_REVERSE);
        mvhline(2, 0, ACS_HLINE, impl_->maxX);
        
        // Draw menu bar
        int x = 2;
        for (int i = 0; i < (int)menuNames.size(); i++) {
            if (i == selectedMenu) {
                attron(A_REVERSE);
                mvaddstr(3, x, menuNames[i].c_str());
                attroff(A_REVERSE);
            } else {
                mvaddstr(3, x, menuNames[i].c_str());
            }
            x += menuNames[i].length() + 4;
        }
        
        // Draw content based on selected menu
        int y = 5;
        switch (selectedMenu) {
            case 0: // Archivo
                mvaddstr(y++, 2, "Archivo:");
                mvaddstr(y++, 4, "1. Abrir archivo de datos...");
                mvaddstr(y++, 4, "2. Guardar buffer a archivo");
                mvaddstr(y++, 4, "3. Salir");
                break;
                
            case 1: // Comando
                mvaddstr(y++, 2, "Comandos:");
                mvaddstr(y++, 4, "1. Leer chip");
                mvaddstr(y++, 4, "2. Programar chip");
                mvaddstr(y++, 4, "3. Borrar chip");
                mvaddstr(y++, 4, "4. Verificar chip");
                mvaddstr(y++, 4, "5. Comparar buffers");
                break;
                
            case 2: // Ajustes
                mvaddstr(y++, 2, "Ajustes:");
                mvaddstr(y++, 4, "1. Dispositivo: ");
                mvaddstr(y, 18, impl_->currentDevice.c_str()); y++;
                mvaddstr(y++, 4, "2. Puerto: ");
                mvaddstr(y, 18, impl_->currentPort.c_str()); y++;
                mvaddstr(y++, 4, "3. Opciones generales");
                break;
                
            case 3: // Buffer
                mvaddstr(y++, 2, "Buffers:");
                for (int i = 0; i < 5; i++) {
                    std::string bufLine = std::to_string(i+1) + ". Buffer " + std::to_string(i+1) + " - " + impl_->bufferStatus[i];
                    mvaddstr(y++, 4, bufLine.c_str());
                }
                break;
                
            case 4: // Hardware
                mvaddstr(y++, 2, "Hardware:");
                mvaddstr(y++, 4, "1. Configurar hardware (JDM)");
                mvaddstr(y++, 4, "2. Prueba de hardware");
                mvaddstr(y++, 4, "3. Interface: Direct I/O");
                break;
                
            case 5: // Ayuda
                mvaddstr(y++, 2, "Ayuda:");
                mvaddstr(y++, 4, "1. Acerca de IC-Prog");
                mvaddstr(y++, 4, "2. Documentación");
                break;
        }
        
        // Draw status bar
        mvhline(impl_->maxY - 2, 0, ACS_HLINE, impl_->maxX);
        mvaddstr(impl_->maxY - 1, 2, "F1-Archivo  F2-Comando  F3-Ajustes  F4-Buffer  F5-Hardware  F10-Salir");
        
        // Draw device info
        mvaddstr(impl_->maxY - 4, 2, "Dispositivo: ");
        mvaddstr(impl_->maxY - 4, 16, impl_->currentDevice.c_str());
        mvaddstr(impl_->maxY - 3, 2, "Puerto: ");
        mvaddstr(impl_->maxY - 3, 10, impl_->currentPort.c_str());
        mvaddstr(impl_->maxY - 2, 2, "Buffer activo: ");
        mvaddstr(impl_->maxY - 2, 16, std::to_string(impl_->currentBuffer + 1).c_str());
        
        refresh();
        
        int c = getch();
        switch (c) {
            case KEY_LEFT:
            case '\t':
                selectedMenu = (selectedMenu + menuNames.size() - 1) % menuNames.size();
                break;
            case KEY_RIGHT:
                selectedMenu = (selectedMenu + 1) % menuNames.size();
                break;
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
                selectedItem = c - '1';
                break;
            case KEY_F(1): selectedMenu = 0; break;
            case KEY_F(2): selectedMenu = 1; break;
            case KEY_F(3): selectedMenu = 2; break;
            case KEY_F(4): selectedMenu = 3; break;
            case KEY_F(5): selectedMenu = 4; break;
            case KEY_F(10):
            case 'q':
            case 'Q':
                impl_->running = false;
                break;
            case KEY_ENTER:
            case '\n':
                // Execute action based on selection
                break;
        }
    }
    
    endwin();
}

} // namespace icprog