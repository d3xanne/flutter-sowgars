"""
Generate a high-quality, professional app icon for FARM Hub
"""
from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon():
    """Create a professional app icon with crisp edges and modern design"""
    
    # Icon size - use 1024x1024 for maximum quality
    size = 1024
    icon = Image.new('RGB', (size, size), color='#2E7D32')  # Forest Green background
    draw = ImageDraw.Draw(icon)
    
    # Enable high-quality rendering
    icon = icon.convert('RGBA')
    draw = ImageDraw.Draw(icon)
    
    # Calculate safe zone (80% of icon size for adaptive icons)
    safe_zone = int(size * 0.8)
    padding = (size - safe_zone) // 2
    
    # Draw a modern tractor design with crisp edges
    # Main body (rectangle with rounded top)
    body_width = int(safe_zone * 0.5)
    body_height = int(safe_zone * 0.3)
    body_x = (size - body_width) // 2
    body_y = size // 2 - body_height // 2
    
    # Draw tractor body (rounded rectangle)
    body_coords = [
        (body_x, body_y + body_height * 0.3),
        (body_x + body_width, body_y + body_height)
    ]
    draw.rounded_rectangle(
        body_coords,
        radius=int(body_width * 0.1),
        fill='white',
        outline='white',
        width=0
    )
    
    # Draw cabin (smaller rounded rectangle on top)
    cabin_width = int(body_width * 0.4)
    cabin_height = int(body_height * 0.5)
    cabin_x = body_x + int(body_width * 0.55)
    cabin_y = body_y + int(body_height * 0.1)
    
    cabin_coords = [
        (cabin_x, cabin_y),
        (cabin_x + cabin_width, cabin_y + cabin_height)
    ]
    draw.rounded_rectangle(
        cabin_coords,
        radius=int(cabin_width * 0.15),
        fill='white',
        outline='white',
        width=0
    )
    
    # Draw wheels (circles)
    wheel_radius = int(safe_zone * 0.12)
    
    # Front wheel
    front_wheel_x = body_x + int(body_width * 0.25)
    front_wheel_y = body_y + body_height + int(wheel_radius * 0.3)
    draw.ellipse(
        [
            front_wheel_x - wheel_radius,
            front_wheel_y - wheel_radius,
            front_wheel_x + wheel_radius,
            front_wheel_y + wheel_radius
        ],
        fill='white',
        outline='white',
        width=0
    )
    
    # Back wheel
    back_wheel_x = body_x + int(body_width * 0.75)
    back_wheel_y = front_wheel_y
    draw.ellipse(
        [
            back_wheel_x - wheel_radius,
            back_wheel_y - wheel_radius,
            back_wheel_x + wheel_radius,
            back_wheel_y + wheel_radius
        ],
        fill='white',
        outline='white',
        width=0
    )
    
    # Draw wheel details (inner circles for depth)
    inner_wheel_radius = int(wheel_radius * 0.6)
    
    # Front wheel inner
    draw.ellipse(
        [
            front_wheel_x - inner_wheel_radius,
            front_wheel_y - inner_wheel_radius,
            front_wheel_x + inner_wheel_radius,
            front_wheel_y + inner_wheel_radius
        ],
        fill='#2E7D32',
        outline='#2E7D32',
        width=0
    )
    
    # Back wheel inner
    draw.ellipse(
        [
            back_wheel_x - inner_wheel_radius,
            back_wheel_y - inner_wheel_radius,
            back_wheel_x + inner_wheel_radius,
            back_wheel_y + inner_wheel_radius
        ],
        fill='#2E7D32',
        outline='#2E7D32',
        width=0
    )
    
    # Draw exhaust pipe (small rectangle)
    exhaust_width = int(safe_zone * 0.04)
    exhaust_height = int(safe_zone * 0.15)
    exhaust_x = body_x + int(body_width * 0.15)
    exhaust_y = body_y + int(body_height * 0.2)
    
    draw.rectangle(
        [
            exhaust_x,
            exhaust_y,
            exhaust_x + exhaust_width,
            exhaust_y + exhaust_height
        ],
        fill='white',
        outline='white',
        width=0
    )
    
    # Add subtle shadow effect for depth (optional gradient overlay)
    # Create a subtle gradient overlay for professional look
    overlay = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay)
    
    # Add subtle highlight at top
    highlight_y = int(size * 0.1)
    for i in range(highlight_y):
        alpha = int(30 * (1 - i / highlight_y))
        overlay_draw.rectangle(
            [(0, i), (size, i + 1)],
            fill=(255, 255, 255, alpha)
        )
    
    # Composite the overlay
    icon = Image.alpha_composite(icon, overlay)
    
    # Ensure the icon is crisp by using high-quality resampling
    # Save with maximum quality
    output_path = 'assets/icons/app_icon.png'
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    # Save as PNG with maximum quality
    icon.save(output_path, 'PNG', optimize=False, compress_level=0)
    
    print(f"✅ High-quality app icon generated at {output_path}")
    print(f"   Size: {size}x{size} pixels")
    print(f"   Background: #2E7D32 (Forest Green)")
    print(f"   Design: Modern tractor silhouette with crisp edges")
    
    return output_path

if __name__ == '__main__':
    try:
        create_app_icon()
    except ImportError:
        print("❌ Error: PIL (Pillow) is required. Install it with: pip install Pillow")
    except Exception as e:
        print(f"❌ Error generating icon: {e}")

