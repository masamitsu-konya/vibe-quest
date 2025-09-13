#!/usr/bin/env python3
"""
SQLファイルから質問テキストを抽出して重複を検出するスクリプト
"""

import re
import os
from collections import defaultdict

def extract_questions_from_sql(file_path):
    """SQLファイルから質問テキストを抽出"""
    questions = []

    if not os.path.exists(file_path):
        print(f"ファイルが見つかりません: {file_path}")
        return questions

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # INSERT文から質問テキストを抽出するパターン
    # ('質問テキスト', 'category', score, tags) の形式
    pattern = r"\('([^']+)',\s*'[^']+',\s*[0-9.]+,\s*ARRAY\["

    lines = content.split('\n')
    for line_num, line in enumerate(lines, 1):
        matches = re.findall(pattern, line)
        for question_text in matches:
            questions.append({
                'text': question_text,
                'line': line_num,
                'file': os.path.basename(file_path)
            })

    return questions

def main():
    # ファイルパス
    files = [
        '/Users/masamitsukonya/Documents/apps/vibe_quest/supabase/seed_questions_1000.sql',
        '/Users/masamitsukonya/Documents/apps/vibe_quest/supabase/seed_questions_501_1000.sql',
        '/Users/masamitsukonya/Documents/apps/vibe_quest/supabase/seed_questions_final_200.sql'
    ]

    # 各ファイルから質問を抽出
    all_questions = []
    file_stats = {}

    for file_path in files:
        questions = extract_questions_from_sql(file_path)
        all_questions.extend(questions)
        file_stats[os.path.basename(file_path)] = len(questions)
        print(f"{os.path.basename(file_path)}: {len(questions)}個の質問を検出")

    print(f"\n合計: {len(all_questions)}個の質問")

    # 重複を検出
    question_map = defaultdict(list)
    for question in all_questions:
        question_map[question['text']].append(question)

    # 重複の報告
    duplicates = {text: locations for text, locations in question_map.items() if len(locations) > 1}

    if duplicates:
        print(f"\n🚨 重複発見: {len(duplicates)}個の重複する質問テキストがあります\n")

        for question_text, locations in duplicates.items():
            print(f"重複質問: '{question_text}'")
            for location in locations:
                print(f"  - {location['file']} の {location['line']}行目")
            print()
    else:
        print("\n✅ 重複なし: すべての質問テキストはユニークです")

    # 統計情報
    print("=== ファイル別統計 ===")
    for file_name, count in file_stats.items():
        print(f"{file_name}: {count}個")

    print(f"\n合計質問数: {len(all_questions)}個")
    print(f"ユニーク質問数: {len(question_map)}個")

    if duplicates:
        total_duplicates = sum(len(locations) - 1 for locations in duplicates.values())
        print(f"重複による余分な質問数: {total_duplicates}個")

if __name__ == "__main__":
    main()