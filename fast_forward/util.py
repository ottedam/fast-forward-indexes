import logging
from collections import defaultdict
from fast_forward.ranking import Ranking
import csv


LOGGER = logging.getLogger(__name__)


def interpolate(
    r1: Ranking, r2: Ranking, method: str, weight: float, name: str = None, sort: bool = True
) -> Ranking:
    """Interpolate scores. For each query-doc pair:
        * If the pair has only one score, ignore it.
        * If the pair has two scores, interpolate using the selected method (CC or RRF).

    Args:
        r1 (Ranking): Scores from the first retriever.
        r2 (Ranking): Scores from the second retriever.
        method (str): One of CC (convex combination) or RRF (reciprocal rank fusion)
        weight (float): Interpolation weight (alpha for CC and eta for RRF)
        name (str, optional): Ranking name. Defaults to None.
        sort (bool, optional): Whether to sort the documents by score. Defaults to True.

    Returns:
        Ranking: Interpolated ranking.
    """
    assert r1.q_ids == r2.q_ids # both lists must have the same queries
    results = defaultdict(dict) 
    for q_id in r1:
        for doc_id in r1[q_id].keys() & r2[q_id].keys():
            #IMPORTANT: RUN SELECTED METHOD
            if method == "CC":
                #r1[q_id][doc_id] returns the SCORE of document doc_id to query q_id according to retrieval system r1
                results[q_id][doc_id] = (weight * r1[q_id][doc_id] + (1 - weight) * r2[q_id][doc_id])
            elif method ==  "RRF":
                results[q_id][doc_id] = (1/(weight + r1.get_rank(q_id=q_id, doc_id=doc_id))) + (1/(weight + r2.get_rank(q_id=q_id, doc_id=doc_id)))
            else:
                raise ValueError('The interpolation method must be either "CC" or "RRF"')
            
    #rank_r1 = r1.get_rank(q_id=q_id, doc_id=doc_id)
    #print("For r1, document ", doc_id, "has rank: ", rank_r1, "given query ", q_id)
    #rank_r2 = r2.get_rank(q_id=q_id, doc_id=doc_id)
    #print("For r2, document ", doc_id, "has rank: ", rank_r2, "given query ", q_id)

    return Ranking(run = results, name=name, sort=sort, copy=False)
