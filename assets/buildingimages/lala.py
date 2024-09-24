import os
from tkinter import filedialog, messagebox
import tkinter as tk
from PIL import Image, ImageEnhance, ImageOps, ImageTk
import numpy as np


# Helper functions for effects
def clamp_color(value, min_val=0, max_val=255):
    return max(min_val, min(value, max_val))


def clamp_image_colors(img):
    pixels = img.load()
    for y in range(img.height):
        for x in range(img.width):
            if len(pixels[x, y]) == 3:  # RGB
                r, g, b = pixels[x, y]
                pixels[x, y] = (clamp_color(r), clamp_color(g), clamp_color(b))
            elif len(pixels[x, y]) == 4:  # RGBA
                r, g, b, a = pixels[x, y]
                pixels[x, y] = (clamp_color(r), clamp_color(g), clamp_color(b), a)
    return img


def apply_grayscale_tint(img, tint_color=(50, 100, 50)):
    img = img.convert('L')
    img = Image.merge("RGB", (img, img, img))
    tinted_img = Image.blend(img, Image.new('RGB', img.size, tint_color), 0.3)
    return tinted_img


def add_noise(img, noise_level=30):
    np_img = np.array(img)
    noise = np.random.randint(-noise_level, noise_level, np_img.shape, dtype='int16')
    np_img = np.clip(np_img + noise, 0, 255).astype('uint8')
    return Image.fromarray(np_img)


def apply_fog_overlay(img, fog_opacity=0.3):
    fog = Image.new('RGBA', img.size, (200, 200, 200, int(fog_opacity * 255)))
    return Image.alpha_composite(img.convert("RGBA"), fog).convert("RGB")


def apply_vignette(img):
    width, height = img.size
    vignette = Image.new("L", (width, height))
    for y in range(height):
        for x in range(width):
            distance_to_center = ((x - width // 2) ** 2 + (y - height // 2) ** 2) ** 0.5
            vignette.putpixel((x, y), int(min(255, distance_to_center / max(width, height) * 255)))
    vignette = vignette.resize(img.size)
    return Image.composite(img, Image.new('RGB', img.size, (0, 0, 0)), vignette)


def apply_glitch(img):
    width, height = img.size
    img_array = np.array(img)
    for i in range(0, height, 10):
        offset = np.random.randint(-10, 10)
        img_array[i:i+10, :] = np.roll(img_array[i:i+10, :], offset, axis=0)
    return Image.fromarray(img_array)


def apply_high_contrast(img, contrast_level=2.0):
    img = img.convert('L')
    contrast_img = ImageEnhance.Contrast(img).enhance(contrast_level)
    return contrast_img.convert('RGB')


# GUI Class
class ImageProcessorGUI(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Image Processor - Pollution Game Style")
        self.geometry("800x600")

        # Load and display the image
        self.img = None
        self.original_img = None
        self.displayed_img = None

        # Sliders for parameters
        self.noise_level = tk.DoubleVar(value=30)
        self.fog_opacity = tk.DoubleVar(value=0.3)
        self.contrast_level = tk.DoubleVar(value=2.0)

        # Image display canvas
        self.canvas = tk.Canvas(self, width=400, height=400, bg='gray')
        self.canvas.grid(row=0, column=0, rowspan=10)

        # Buttons for loading, saving, and applying effects
        load_button = tk.Button(self, text="Load Image", command=self.load_image)
        load_button.grid(row=0, column=1)

        save_button = tk.Button(self, text="Save Image", command=self.save_image)
        save_button.grid(row=1, column=1)

        # Add sliders
        self.add_sliders()

        # Effects buttons
        self.add_effect_buttons()

    def add_sliders(self):
        # Noise Level Slider
        noise_slider_label = tk.Label(self, text="Noise Level")
        noise_slider_label.grid(row=2, column=1)
        noise_slider = tk.Scale(self, from_=0, to=100, orient='horizontal', variable=self.noise_level)
        noise_slider.grid(row=3, column=1)

        # Fog Opacity Slider
        fog_slider_label = tk.Label(self, text="Fog Opacity")
        fog_slider_label.grid(row=4, column=1)
        fog_slider = tk.Scale(self, from_=0, to=1, resolution=0.01, orient='horizontal', variable=self.fog_opacity)
        fog_slider.grid(row=5, column=1)

        # Contrast Level Slider
        contrast_slider_label = tk.Label(self, text="Contrast Level")
        contrast_slider_label.grid(row=6, column=1)
        contrast_slider = tk.Scale(self, from_=1, to=3, resolution=0.1, orient='horizontal', variable=self.contrast_level)
        contrast_slider.grid(row=7, column=1)

    def add_effect_buttons(self):
        # Add effect buttons
        effects = [
            ("Clamp Colors", self.clamp_colors),
            ("Grayscale + Tint", self.apply_grayscale_tint),
            ("Add Noise", self.apply_noise),
            ("Fog Overlay", self.apply_fog),
            ("Vignette", self.apply_vignette),
            ("Glitch", self.apply_glitch),
            ("High Contrast", self.apply_high_contrast)
        ]
        for i, (label, effect_func) in enumerate(effects, start=8):
            button = tk.Button(self, text=label, command=effect_func)
            button.grid(row=i, column=1)

    def load_image(self):
        file_path = filedialog.askopenfilename(filetypes=[("Image Files", "*.png;*.jpg;*.jpeg")])
        if file_path:
            self.img = Image.open(file_path)
            self.original_img = self.img.copy()
            self.display_image(self.img)

    def save_image(self):
        if self.img:
            file_path = filedialog.asksaveasfilename(defaultextension=".png", filetypes=[("PNG files", "*.png")])
            if file_path:
                self.img.save(file_path)
                messagebox.showinfo("Save Image", "Image saved successfully!")

    def display_image(self, img):
        self.displayed_img = ImageTk.PhotoImage(img.resize((400, 400)))
        self.canvas.create_image(200, 200, image=self.displayed_img, anchor=tk.CENTER)

    # Effect application functions
    def clamp_colors(self):
        if self.img:
            self.img = clamp_image_colors(self.img.copy())
            self.display_image(self.img)

    def apply_grayscale_tint(self):
        if self.img:
            self.img = apply_grayscale_tint(self.img.copy())
            self.display_image(self.img)

    def apply_noise(self):
        if self.img:
            noise_level = self.noise_level.get()
            self.img = add_noise(self.img.copy(), noise_level=noise_level)
            self.display_image(self.img)

    def apply_fog(self):
        if self.img:
            fog_opacity = self.fog_opacity.get()
            self.img = apply_fog_overlay(self.img.copy(), fog_opacity=fog_opacity)
            self.display_image(self.img)

    def apply_vignette(self):
        if self.img:
            self.img = apply_vignette(self.img.copy())
            self.display_image(self.img)

    def apply_glitch(self):
        if self.img:
            self.img = apply_glitch(self.img.copy())
            self.display_image(self.img)

    def apply_high_contrast(self):
        if self.img:
            contrast_level = self.contrast_level.get()
            self.img = apply_high_contrast(self.img.copy(), contrast_level=contrast_level)
            self.display_image(self.img)


if __name__ == "__main__":
    app = ImageProcessorGUI()
    app.mainloop()
