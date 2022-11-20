import requests
import shutil
import json
import os

def main():
    print(os.getcwd())
    base_api_url = 'https://api.scryfall.com/symbology'
    res = requests.get(base_api_url)
    if res.status_code == 200:
        content = json.loads(res.content)
        data = content['data']
        for card_symbol in data:
            file_path = 'assets/images'
            file_name = f'{card_symbol["symbol"].replace("{", "").replace("}", "").replace("/", "-")}.svg'
            full_path = f'{file_path}/{file_name}'
            file_res = requests.get(card_symbol['svg_uri'], stream=True)
            if file_res.status_code == 200:
                data = file_res.content
                with open(full_path, 'wb') as f:
                    f.write(data)
                    # shutil.copyfileobj(file_res.raw, f)
                print(f'image successfully downloaded: {full_path}')
                # break
            else:
                print(f'image download error on: {full_path}')

if __name__ == '__main__':
    main()