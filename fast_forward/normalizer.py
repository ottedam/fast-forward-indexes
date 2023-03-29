from collections import OrderedDict, defaultdict
import math
import numpy as np
from typing import Dict

Run = Dict[str, Dict[str, float]]

def normalize_run(run: Run, type: str) -> "Run":
    
    # create empty Run instance that will be filled
    normalized_run = defaultdict(OrderedDict)

    # return normalized run according to the type
    if type == "MM": # min-max scaling
        for q_id, scores_dict in run.items():
            min_score = scores_dict[min(scores_dict, key=scores_dict.get)]
            max_score = scores_dict[max(scores_dict, key=scores_dict.get)]
            normalized_inner_dict = {k:(v-min_score)/(max_score-min_score) for k,v in scores_dict.items()}
            normalized_run[q_id] = normalized_inner_dict
    elif type == "TMM": # thoeretical min-max scaling
        for q_id, scores_dict in run.items():
            max_score = scores_dict[max(scores_dict, key=scores_dict.get)]
            normalized_inner_dict = {k:(v)/(max_score) for k,v in scores_dict.items()}
            normalized_run[q_id] = normalized_inner_dict        
    elif type == "Z": # z-score normalization
        for q_id, scores_dict in run.items():
            mu = np.array(list(scores_dict.values())).mean()
            sigma = np.array(list(scores_dict.values())).std()
            normalized_inner_dict = {k:(v-mu)/(sigma) for k,v in scores_dict.items()}
            normalized_run[q_id] = normalized_inner_dict
    #elif type == "LOG": # log scaling
    #    for q_id, scores_dict in run.items():
    #        normalized_inner_dict = {k:math.log(v) for k,v in scores_dict.items()}
    #        normalized_run[q_id] = normalized_inner_dict    
    else:
        raise ValueError('Normalization method not supported')

    return normalized_run