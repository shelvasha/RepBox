import os, shutil


def find_missing_items(directory):
    provided_list = ['repbox_config.txt', 'bin', 'utils', 'genome', 'included', 'results', 'main.py', 'README.md', 'Changelog.md']
    directory_items = os.listdir(os.path.dirname(directory))
    missing_items = []
    for item in directory_items:
        if not item.startswith('.') and item not in provided_list:
            missing_items.append(item)
    return missing_items

def search_directories_for_fastas(directory=os.getcwd()):
    list_of_fastas_to_merge = []
    missing_items = find_missing_items(directory)
    for item in missing_items:
        answer = input('Is your directory name the following?: %s \n[y|n]' % item)
        if answer == 'y':
            os.chdir(os.getcwd())
            print('Searching directories for output .fasta(s) from pipeline...')
            paths = os.getcwd()
            # print(paths)
            for directory in os.listdir(paths):
                directory_path = os.path.join(paths, directory)  # Create the full path to the directory
                if not os.path.isdir(directory_path):  # Skip files that are not directories
                    continue
                # print(directory)
                for file_name in os.listdir(directory_path):
                    if 'sine' in file_name:
                        if file_name.endswith('.sine.fa'):
                            # print(file_name)
                            list_of_fastas_to_merge.append(paths + '/' + directory + '/' + file_name)
                    elif 'helitron' in file_name:
                        if file_name.endswith('.hel.fa'):
                            # print(file_name)
                            list_of_fastas_to_merge.append(paths + '/' + directory + '/' + file_name)
                    elif 'mitefinder' in file_name:
                        if file_name.endswith('.fasta'):
                            # print(file_name)
                            list_of_fastas_to_merge.append(paths + '/' + directory + '/' + file_name)
                    elif 'consensi' in file_name:
                        if file_name.endswith('.classified'):
                            # print(file_name)
                            list_of_fastas_to_merge.append(paths + '/' + directory + '/' + file_name)
            if not os.listdir(paths):
                print('No files found. Exiting pipeline.')
    return list_of_fastas_to_merge

def concatenate_fasta_files(input_files, output_directory, output_filename):
    output_path = output_directory + "/" + output_filename
    with open(output_path, "w") as output_file:
        for input_file in input_files:
            with open(input_file, "r") as fasta_file:
                for line in fasta_file:
                    output_file.write(line)


def check_and_cleanup_directory():
    src_directory = os.path.abspath(os.getcwd())
    dest_directory = os.path.dirname(os.path.abspath(os.getcwd())) + '/results'
    try:
        os.mkdir(dest_directory)
        print("Results directory %s exists. Moving outputs to results directory." % dest_directory)
    except Exception:
        print("Results directory %s exists. Moving outputs to results directory." % dest_directory)
    shutil.move(src_directory, dest_directory)
