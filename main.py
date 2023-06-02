from utils.selection import *
import re
import sys
import subprocess
import ast
import multiprocessing
import glob
import os
import shutil
import math

## Open the file in read mode
with open("repbox_config.txt", "r") as file:
    # Read the lines and evaluate each line as a dictionary
    lines = [ast.literal_eval(line) for line in file]
    # print(lines)
    for line in lines:
        variable_name = str(list(line.keys())[0])
        value = str(list(line.values())[0])
        globals()[variable_name] = value
        # print(value)

def count_fasta_sequences(input_file):
    seq_count = 0
    with open(input_file, 'r') as fasta_file:
        for line in fasta_file:
            if line.startswith('>'):
                seq_count += 1

    return seq_count

def calculate_ideal_threads():
    num_cpus = multiprocessing.cpu_count()
    ideal_threads =  math. floor(num_cpus/4)
    # print(ideal_threads)
    return int(num_cpus)

if __name__ == "__main__":
    threads = calculate_ideal_threads()

# Define RepeatModeler
def run_repeatmodeler(input_file, processes=threads):
    try:
        print("Reading input fasta:  %s..." % (input_file) )
        # First command: BuildDatabase
        build_db_command = [
            BuildDatabase,
            input_file,
            "-name", input_file.split('.')[0],
            "-engine","ncbi",
            "-dir", os.path.dirname(input_file)
        ]

        # Execute the BuildDatabase command
        build_db_process = subprocess.run(build_db_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        build_db_stdout = build_db_process.stdout.decode()
        build_db_stderr = build_db_process.stderr.decode()

        if build_db_process.returncode == 0:
            print("Success: BuildDatabase complete.")
        else:
            print("Error running BuildDatabase. Exit code:", build_db_process.returncode)
            print("Error message:", build_db_stderr)

        # Second command: RepeatModeler
        repeat_modeler_command = [
            RepeatModeler,
            "-engine", "ncbi",
            "-database" ,input_file.split('.')[0],
            "-pa", str(processes),
            # "-LTRStruct"
        ]


        # Execute the RepeatModeler command
        print('Running RepeatModeler...')
        repeat_modeler_process = subprocess.run(repeat_modeler_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        repeat_modeler_stdout = repeat_modeler_process.stdout.decode()
        repeat_modeler_stderr = repeat_modeler_process.stderr.decode()

        if repeat_modeler_process.returncode == 0:
            print("Success: RepeatModeler complete.")
        else:
            print("Error running RepeatModeler. Exit code:", repeat_modeler_process.returncode)
            print("Error message:", repeat_modeler_stderr)

    except FileNotFoundError:
        print("RepeatModeler command not found. Make sure it is installed and/or in your system PATH.")

# Define RepeatMasker
def run_repeatmasker(genome, library='', processes=threads, engine='ncbi', output_dir=''):
    try:
        if library == '':
            # repeat_masker_command
            repeat_masker_command = [
                RepeatMasker,
                "-pa", str(processes),
                "-engine", engine,
                "-u", genome,
                "-dir", output_dir,
                "-qq"
            ]
        else:
            # repeat_masker_command
            repeat_masker_command = [
                RepeatMasker,
                "-pa", str(processes),
                "-engine", engine,
                "lib", library,
                "-u", genome,
                "-dir", output_dir,
                "-qq"
            ]


        print('Library: ', library)
        print('Engine: ', engine)
        print('Genome: ', genome)
        print('Output directory: ', output_dir)


        # Execute the BuildDatabase command
        print('Running RepeatMasker...')
        repeat_masker_process = subprocess.run(repeat_masker_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        repeat_masker_stdout = repeat_masker_process.stdout.decode()
        repeat_masker_stderr = repeat_masker_process.stderr.decode()

        if repeat_masker_process.returncode == 0:
            print("Success: RepeatMasker complete.")
        else:
            print("Error running RepeatMasker. Exit code:", repeat_masker_process.returncode)
            print("Error message:", repeat_masker_stderr)

    except FileNotFoundError:
        print("RepeatMasker command not found. Make sure it is installed and in the system PATH.")

# Define MiteFinderII
def run_mitefinder(input_filename, threshold=0.0):
    output_dir = os.getcwd() + '/mitefinder_output'
    os.mkdir(output_dir)

    def reformat_fasta(file_path):
        with open(file_path, 'r') as file:
            fasta_lines = file.readlines()

        formatted_lines = []
        for line in fasta_lines:
            if line.startswith('>'):
                header_parts = line.strip().split('|')
                new_header = '_'.join(
                    part.replace(':', '_') for part in header_parts[1:])  # Replace '|' and ':' with '_'
                formatted_lines.append('>' + new_header + '\n')
            else:
                formatted_lines.append(line)

        formatted_file = ''.join(formatted_lines)
        return formatted_file

    try:
        # Third command: repeat_masker_command
        mitefinder_command = [
            miteFinder,
            "-input", str(input_filename),
            "-threshold", str(float(threshold)),
            "-output", str(output_dir + '/' + re.search(r'[^/]+(?=\.[^.]+$)', input_filename).group() + "_mitefinder.fasta"),
            "-pattern_scoring", os.path.dirname(os.path.dirname(miteFinder)) + '/' + "profile/pattern_scoring.txt",
        ]

        # Execute the BuildDatabase command
        print('Running miteFinder...')
        mitefinder_process = subprocess.run(mitefinder_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        mitefinder_stdout = mitefinder_process.stdout.decode()
        mitefinder_stderr = mitefinder_process.stderr.decode()

        if mitefinder_process.returncode == 0:
            print("Success: miteFinder complete.")
        else:
            print("Error running miteFinder. Exit code:", mitefinder_process.returncode)
            print("Error message:", mitefinder_stderr)

    except FileNotFoundError:
        print("miteFinder command not found. Make sure it is installed and in the system PATH.")

    # Reformatting of Mitefinder output
    formatted_data = reformat_fasta( str(output_dir + '/' + re.search(r'[^/]+(?=\.[^.]+$)', input_filename).group() + "_mitefinder.fasta") )
    output_file = str(output_dir + '/' + re.search(r'[^/]+(?=\.[^.]+$)', input_filename).group() + "_mitefinder.fasta")
    with open(output_file, 'w') as file:
        file.write(formatted_data)

# Define HelitronScanner
def run_helitronscanner(input_filename, processes=threads, output_dir=''):
    output_dir = str(os.getcwd()  + '/helitronscanner_output')
    os.mkdir(output_dir)

## Begin HelitronScanner
    print('Running HelitronScanner...')
    try:
    ## Step 1: Execute the HelitronScanner scanHead command
        helitronscanner_command = [
            "java",
            "-jar", HelitronScanner,
            "scanHead",
            "-lf", os.path.dirname(os.path.dirname(HelitronScanner)) + "/TrainingSet/head.lcvs",
            "-g", input_filename,
            "-bs", str(0),
            "-o", output_dir + '/' + re.search(r'[^/]+(?=\.[^.]+$)', input_filename).group() + '_helitron' + '.head',
            "-tl", str(processes)
        ]

        # Execute the HelitronScanner scanHead command
        helitronscanner_process = subprocess.run(helitronscanner_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        helitronscanner_stdout = helitronscanner_process.stdout.decode()
        helitronscanner_stderr = helitronscanner_process.stderr.decode()

        if helitronscanner_process.returncode == 0:
            print("HelitronScanner scanHead complete.")
        else:
            print("Error running HelitronScanner scanHead. Exit code:", helitronscanner_process.returncode)
            print("Error message:", helitronscanner_stderr)

    except FileNotFoundError:
        print("HelitronScanner scanHead failed. Exiting HelitronScanner.")


    try:
    ## Step 2: Execute the HelitronScanner scanTail command
        helitronscanner_command = [
            "java",
            "-jar", HelitronScanner,
            "scanTail",
            "-lf", os.path.dirname(os.path.dirname(HelitronScanner)) + "/TrainingSet/tail.lcvs",
            "-g", input_filename,
            "-bs", str(0),
            "-o", output_dir + '/' + re.search(r'[^/]+(?=\.[^.]+$)', input_filename).group() + '_helitron' + '.tail',
            "-tl", str(processes)
        ]


        # Execute the HelitronScanner scanTail command
        helitronscanner_process = subprocess.run(helitronscanner_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        helitronscanner_stdout = helitronscanner_process.stdout.decode()
        helitronscanner_stderr = helitronscanner_process.stderr.decode()

        if helitronscanner_process.returncode == 0:
            print("HelitronScanner scanTail complete.")
        else:
            print("Error running HelitronScanner scanTail. Exit code:", helitronscanner_process.returncode)
            print("Error message:", helitronscanner_stderr)

    except FileNotFoundError:
        print("HelitronScanner scanTail failed. Exiting HelitronScanner.")


    try:
    ## Step 3: Execute the HelitronScanner pairEnds command
        helitronscanner_command = [
            "java",
            "-jar", HelitronScanner,
            "pairends",
            "-hs", output_dir + '/' + re.search(r'[^/]+(?=\.[^.]+$)', input_filename).group() + '_helitron' + '.head',
            "-ts", output_dir + '/' + re.search(r'[^/]+(?=\.[^.]+$)', input_filename).group() + '_helitron' + '.tail',
            "-o", output_dir + '/' + re.search(r'[^/]+(?=\.[^.]+$)', input_filename).group() + '_helitron' + '.paired',
        ]


        # Execute the HelitronScanner scanTail command
        helitronscanner_process = subprocess.run(helitronscanner_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        helitronscanner_stdout = helitronscanner_process.stdout.decode()
        helitronscanner_stderr = helitronscanner_process.stderr.decode()

        if helitronscanner_process.returncode == 0:
            print("HelitronScanner pairEnds complete.")
        else:
            print("Error running HelitronScanner pairEnds. Exit code:", helitronscanner_process.returncode)
            print("Error message:", helitronscanner_stderr)

    except FileNotFoundError:
        print("HelitronScanner pairEnds failed. Exiting HelitronScanner.")


    try:
    ## Step 4: Execute draw command - Create the fasta sequences from paired for each helitrons
        helitronscanner_command = [
            "java",
            "-jar", HelitronScanner,
            "draw",
            "-p", output_dir + '/' + re.search(r'[^/]+(?=\.[^.]+$)', input_filename).group() + '_helitron'+ '.paired',
            "-g", input_filename,
            "-o", output_dir + '/' + re.search(r'[^/]+(?=\.[^.]+$)', input_filename).group() + '_helitron',
            "-pure_helitron"
        ]


        # Execute the HelitronScanner scanTail command
        helitronscanner_process = subprocess.run(helitronscanner_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        helitronscanner_stdout = helitronscanner_process.stdout.decode()
        helitronscanner_stderr = helitronscanner_process.stderr.decode()

        if helitronscanner_process.returncode == 0:
            print("HelitronScanner draw complete.")
        else:
            print("Error running HelitronScanner draw. Exit code:", helitronscanner_process.returncode)
            print("Error message:", helitronscanner_stderr)

    except FileNotFoundError:
        print("HelitronScanner draw failed. Exiting HelitronScanner.")
    # print("HelitronScanner command not found. Make sure it is installed and in the system PATH.")

# Define SineScan
def run_sinescan(input_filename, processes=threads, output_dir=''):
    output_dir = str(os.getcwd() + '/sinescan_output')
    os.mkdir(output_dir)
    os.chdir(os.path.dirname(SineScan))

    try:
        sinescan_command = [
            "perl", SineScan,
            "-g", str(input_filename),
            "-d", str(output_dir),
            "-k", str(processes),
            "-s", "123",
            "-o", str(output_dir)
        ]

        # Execute the SineScan command
        print('Running SineScan...')
        sinescan_process = subprocess.run(sinescan_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        sinescan_stdout = sinescan_process.stdout.decode()
        sinescan_stderr = sinescan_process.stderr.decode()

        if sinescan_process.returncode == 0:
            print("Success: SineScan complete.")
        else:
            print("Error running SineScan. Exit code:", sinescan_process.returncode)
            print("Error message:", sinescan_stderr)

    except FileNotFoundError:
        print("Sine_scan_process.pl not found. Make sure it is installed and/or in the system PATH.")

    os.chdir(home_dir)

def run_vsearch(input_filename, output_name='', processes=threads):
    output_dir = os.getcwd()

    ## Clustering
    # Finding missing items using find_missing_items function
    directory = os.getcwd()
    print(directory)

    # Searching directories for .fasta files using search_directories_for_fastas function
    list_of_fastas_to_merge = search_directories_for_fastas(directory)
    print("Identified %d .fasta(s) to merge." % len(list_of_fastas_to_merge))
    # print(list_of_fastas_to_merge)

    # Assigning clustering output directory
    cl_output_directory = home_dir + '/consensus_output'
    print("Clustering output directory: ",cl_output_directory)

    os.mkdir(cl_output_directory)
    concatenate_fasta_files(list_of_fastas_to_merge, cl_output_directory, 'merged-library.fa')

    ## Run VSEARCH and Classification using RepeatClassifier
    cluster_input = cl_output_directory + '/final.nr.consensus_edit.fa'
    print('VSEARCH cluster input:', cluster_input)
    os.chdir(cl_output_directory)

    ## Step 1: First VSEARCH Command
    print('Initiating clustering...')

    try:
        vsearch_command = [
            VSEARCH,
            "-sortbylength", "merged-library.fa",
            "--output", "merged-library.sorted.fa",
            "--log", "vsearch.log"
        ]

        # Execute the VSEARCH command
        print('Running VSEARCH - Step 1...')
        vsearch_process = subprocess.run(vsearch_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        vsearch_stdout = vsearch_process.stdout.decode()
        print(vsearch_stdout)

        vsearch_stderr = vsearch_process.stderr.decode()

        if vsearch_process.returncode == 0:
            print("Success: Step 1 complete.")
        else:
            if vsearch_stderr == '':
                print("VSEARCH consensus stdout:", vsearch_stdout)
            else:
                print("Error message:", vsearch_stderr)

    except FileNotFoundError:
        print("VSEARCH not found. Make sure it is installed and/or in the system PATH.")

    ## Step 2: Second VSEARCH Command
    try:
        vsearch_command = [
            VSEARCH,
            "-cluster_fast", "merged-library.fa",
            "--id", str(0.95),
            "--centroids", "my_centroids.fa",
            "--uc", "result.uc",
            "-consout", "final.nr.consensus.fa",
            "-msaout", "aligned.fasta",
            "--log", "vsearch2.log"
        ]

        print('Running VSEARCH - Step 2...')
        vsearch_process = subprocess.run(vsearch_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        vsearch_stdout = vsearch_process.stdout.decode()
        print(vsearch_stdout)

        vsearch_stderr = vsearch_process.stderr.decode()

        if vsearch_process.returncode == 0:
            print("Success: Step 2 complete.")
        else:
            if vsearch_stderr == '':
                print("VSEARCH clustering stdout:", vsearch_stdout)
            else:
                print("Error message:", vsearch_stderr)

    except FileNotFoundError:
        print("VSEARCH not found. Make sure it is installed and/or in the system PATH.")

    ## Step 3 - Renaming and classification of final consensus
    print('Step 3: Renaming and classification of final consensus...')
    input_consensus_file = 'final.nr.consensus.fa'
    output_consensus_file = 'final.nr.consensus_edit.fa'

    with open(input_consensus_file, 'r') as input_f, open(output_consensus_file, 'w') as output_f:
        for line in input_f:
            line = re.sub(r'centroid=*', '', line)
            line = re.sub(r';seqs=[0-9]*$', '', line)
            output_f.write(line)
    print('Success: Step 3 complete.')

## Step 4 - Classification Command using RepeatClassifier
    try:
        repeatclassifier_command = [
            RepeatClassifier,
            "-consensi", os.getcwd() + "/final.nr.consensus_edit.fa",
            "-engine", "ncbi",
            "-pa", str(processes)
        ]

        print('Running RepeatClassifier - Step 4...')
        repeatclassifier_process = subprocess.run(repeatclassifier_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        repeatclassifier_stdout = repeatclassifier_process.stdout.decode()
        print(repeatclassifier_stdout)
        repeatclassifier_stderr = repeatclassifier_process.stderr.decode()

        if repeatclassifier_process.returncode == 0:
            print("Success: Step 4 complete.")
        else:
            print("Error running RepeatClassifier. Exit code:", repeatclassifier_process.returncode)
            if repeatclassifier_stderr == '':
                print("RepeatClassifier stdout:", repeatclassifier_stdout)
                print('Check your command:', repeatclassifier_process)
            else:
                print("Error message:", repeatclassifier_stderr)
                print('Check your command:', repeatclassifier_process)


    except FileNotFoundError:
        print("RepeatClassifier not found. Make sure it is installed and/or in the system PATH.")

def run_repbox(input_filename, library='', engine='ncbi', processes=threads, output_dir=''):
    os.chdir(home_dir)
    output_dir = os.getcwd()

    repbox_output_dir = output_dir + "/repbox_output/"
    os.mkdir(repbox_output_dir)
    os.chdir(repbox_output_dir)

    print("building RepBox library from fasta:  %s..." % (library))
    try:
        # First command: BuildDatabase
        build_db_command = [
            BuildDatabase,
            str(output_dir + "/consensus_output/" + library),
            "-name", 'repbox_library',
            "-engine", "ncbi",
            "-dir", home_dir
        ]

        # Execute the BuildDatabase command
        build_db_process = subprocess.run(build_db_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        build_db_stdout = build_db_process.stdout.decode()
        print(build_db_stdout)
        build_db_stderr = build_db_process.stderr.decode()

        if build_db_process.returncode == 0:
            print("Success: BuildDatabase complete.")
        else:
            print("Error running BuildDatabase. Exit code:", build_db_process.returncode)
            print("Error message:", build_db_stderr)
    except FileNotFoundError:
        print("Final database build for RepBox failed.")

    try:
        repbox_command = [
            RepeatMasker,
            input_filename,
            "-pa", str(processes),
            "-engine", engine,
            "lib", 'repbox_library',
            "-dir", repbox_output_dir,
            "-qq"
        ]

        # Execute the final masking command
        print('Running final masking for RepBox...')
        repbox_process = subprocess.run(repbox_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        repbox_stdout = repbox_process.stdout.decode()

        print(repbox_stdout)
        repbox_stderr = repbox_process.stderr.decode()


        if repbox_process.returncode == 0:
            print("Success: final masking complete.")
        else:
            print("Error running final masking step. Exit code:", repbox_process.returncode)
            print("Error message:", repbox_stderr)

    except FileNotFoundError:
        print("Final masking for RepBox failed.")

if __name__ == "__main__":
    if len(sys.argv) != 3: # Should be count of arguments + 1
        print("Usage: python main.py input_file.fasta <output_dir_name>")
    else:

        ## Arguments
        input_file = sys.argv[1]
        output_name = sys.argv[2]
        # arg_3 = sys.argv[3]

        ## Output Directories
        output_dir = os.getcwd() + '/' + output_name

        try:
            os.mkdir(os.getcwd() + '/' + output_name)
        except Exception:
            pass

        ## Copy genome to new directory
        try:
            shutil.copy(input_file, output_dir)
        except Exception:
            pass

        input_file = str(output_dir + '/' + os.path.basename(input_file))

        ## Set home working directory
        os.chdir(os.path.dirname((input_file)))
        home_dir = os.getcwd()


        #### Running of Functions
        ## Count of sequences in .fasta
        seq_count = count_fasta_sequences(input_file)
        print("Number of sequences:", seq_count)

        # ## BuildDatabase and run RepeatModeler
        # print("Home directory: ", home_dir)
        # run_repeatmodeler(input_file=input_file)
        #
        # ## Run RepeatMasker
        # run_repeatmasker(
        #     genome=input_file,
        #     library=glob.glob(home_dir + "/RM*/consensi.fa.classified")[0],
        #     engine='ncbi',
        #     output_dir=home_dir + '/' + 'repeatmasker_out')
        #
        ### Specific TE Identification
        ## Run miteFinder
        run_mitefinder(input_filename=input_file)

        ## Run HelitronScanner
        run_helitronscanner(input_filename=input_file)

        ## Run SineScan
        run_sinescan(input_filename=input_file)

        ## Run VSEARCH
        run_vsearch(input_filename=input_file, output_name=output_name)

        ## RepBox - Repeat-Masking of custom library using RepeatMasker
        run_repbox(input_filename=input_file, library='final.nr.consensus_edit.fa.classified')

        ## Cleanup
        # check_and_cleanup_directory()