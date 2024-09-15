#include <stdio.h>
#include <stdlib.h> 
#include <stdint.h>
#include <math.h>

typedef struct {
    uint8_t r; 
    uint8_t g; 
    uint8_t b; 
} RGB; // 3 x 0 - 255

typedef struct {
    uint8_t h; // 0-360 degrees
    uint8_t s;  // 0-100
    uint8_t v;  // 0-100
    
    
} HSV;

uint8_t default_filter[2][6] = {
    {149, 206, 45, 255, 64, 255},
    {0, 255, 0, 45, 230, 255}
};


HSV rgb_to_hsv(RGB rgb) {
    HSV hsv;
    float hh;
    float r = rgb.r / 255.0f;
    float g = rgb.g / 255.0f;
    float b = rgb.b / 255.0f;

    float cmax = fmaxf(fmaxf(r, g), b);
    float cmin = fminf(fminf(r, g), b);
    float delta = cmax - cmin;

    // Calculate hue
    float hue_index = 0;
    hue_index = (cmax == r) * ((g - b) / delta) +
        (cmax == g) * (((b - r) / delta) + 2) +
        (cmax == b) * (((r - g) / delta) + 4);

    hh = 60 * hue_index;
    hsv.h = (uint8_t) (((hh < 0) ? (hh + 360) : hh) * 255.0f / 360.0f);

    // Calculate saturation
    hsv.s = (cmax == 0) ? 0 : (uint8_t)((delta / cmax) * 255);

    // Calculate value
    hsv.v = (uint8_t)(cmax * 255);

    return hsv;
}
int inference(RGB* frame, uint32_t rows, uint32_t cols, uint8_t filter1[6], uint8_t filter2[6]) {
    uint32_t cumulative = 0;

    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            uint8_t pom = frame[i * cols + j].r;
            frame[i * cols + j].r = frame[i * cols + j].b;
            frame[i * cols + j].b = pom;
            HSV pixel = rgb_to_hsv(frame[i * cols + j]);
            if (pixel.h >= filter1[0] && pixel.h <= filter1[1] && pixel.s >= filter1[2] && pixel.s <= filter1[3]
                && pixel.v >= filter1[4] && pixel.v <= filter1[5]) {
                cumulative = cumulative + 1;
            }
            if (pixel.h >= filter2[0] && pixel.h <= filter2[1] && pixel.s >= filter2[2] && pixel.s <= filter2[3]
                && pixel.v >= filter2[4] && pixel.v <= filter2[5]) {
                cumulative = cumulative + 1;
            }
        }
    }

    return cumulative;
}

RGB* load_image(const char* filename, uint32_t* w, uint32_t* h) {
    FILE* file = fopen(filename, "rb");
    RGB* rgb_array;
    if (file == NULL) {
        printf("fopen failed");
        return NULL;
    }

    fread(w, sizeof(uint32_t), 1, file);
    fread(h, sizeof(uint32_t), 1, file);
    int i;
    size_t tmp;
    rgb_array = (RGB*) malloc((*w) * (*h) * sizeof(RGB));
    if (rgb_array) {
        tmp = fread(rgb_array, sizeof(uint8_t), (*w) * (*h) * 3, file);
    }
    else {
        printf("malloc failed");
    }
   
    fclose(file);
    return rgb_array;
}

int main(int argc, char* argv[]) {
    /*if (argc < 1) {
        printf("No file name");
        return 0;
    }*/
    const char* filename = "C:\\Users\\Iva\\source\\repos\\Project2\\Project2\\Slike\\meta5_jpg.bin";
    RGB* image_buffer;
    uint32_t width, height;

    image_buffer = load_image(filename, &width, &height);

    printf("Target num: %d", inference(image_buffer, width, height, default_filter[0], default_filter[1]));


    free(image_buffer);
    return 0;
}
