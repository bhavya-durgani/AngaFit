import os
import re

def fix_with_opacity():
    for root, _, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                new_content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)
                if new_content != content:
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Fixed withOpacity in {path}")

def fix_use_key():
    files_to_fix = [
        'lib/features/home/categories_screen.dart',
        'lib/features/home/widgets/products_screen.dart',
        'lib/features/reviews/ratings_reviews_screen.dart',
    ]
    for file in files_to_fix:
        path = os.path.join(os.getcwd(), file.replace('/', os.sep))
        if os.path.exists(path):
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            # Replace `const CategoriesScreen();` -> `const CategoriesScreen({super.key});`
            new_content = re.sub(r'const ([A-Za-z0-9]+)\(\);', r'const \1({super.key});', content)
            if new_content != content:
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"Fixed use_key in {path}")

def fix_unused_imports():
    files_to_fix = [
        ('lib/features/catalog/widgets/sort_bottom_sheet.dart', "import '../../../core/constants/app_colors.dart';\n"),
        ('lib/features/profile/settings_screen.dart', "import '../../core/constants/app_colors.dart';\n"),
        ('lib/features/visual_search/visual_search_screen.dart', "import '../../core/constants/app_colors.dart';\n")
    ]
    for file, imp in files_to_fix:
        path = os.path.join(os.getcwd(), file.replace('/', os.sep))
        if os.path.exists(path):
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            new_content = content.replace(imp, '')
            if new_content != content:
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"Fixed unused import in {path}")

def fix_consts():
    # Login screen
    path = os.path.join(os.getcwd(), 'lib', 'features', 'auth', 'login_screen.dart')
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
            content = content.replace('BoxDecoration(', 'const BoxDecoration(')
            content = content.replace('colors: [', 'colors: const [')
            with open(path, 'w', encoding='utf-8') as f2:
                f2.write(content)

if __name__ == '__main__':
    fix_with_opacity()
    fix_use_key()
    fix_unused_imports()
    # fix_consts() # Might break things if not careful, better to fix manually or use standard flutter fix
