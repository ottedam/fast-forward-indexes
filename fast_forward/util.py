import logging
from collections import defaultdict
from fast_forward.ranking import Ranking
import csv


LOGGER = logging.getLogger(__name__)


def interpolate(
    r1: Ranking, r2: Ranking, alpha: float, name: str = None, sort: bool = True
) -> Ranking:
    """Interpolate scores. For each query-doc pair:
        * If the pair has only one score, ignore it.
        * If the pair has two scores, interpolate: r1 * alpha + r2 * (1 - alpha).

    Args:
        r1 (Ranking): Scores from the first retriever.
        r2 (Ranking): Scores from the second retriever.
        alpha (float): Interpolation weight.
        name (str, optional): Ranking name. Defaults to None.
        sort (bool, optional): Whether to sort the documents by score. Defaults to True.

    Returns:
        Ranking: Interpolated ranking.
    """
    assert r1.q_ids == r2.q_ids # both lists must have the same queries
    results = defaultdict(dict) 
    with open(r'C:\Users\Revi\Desktop\scores_2020.csv','a') as f1:
        writer=csv.writer(f1, delimiter=',',lineterminator='\n',)
        for q_id in r1:
            for doc_id in r1[q_id].keys() & r2[q_id].keys():
                row = [q_id,doc_id,r1[q_id][doc_id],r2[q_id][doc_id]]
                writer.writerow(row)
                results[q_id][doc_id] = (
        #IMPORTANT:
                    #r1[q_id][doc_id] returns the SCORE of document doc_id to query q_id according to retrieval system r1
                    alpha * r1[q_id][doc_id] + (1 - alpha) * r2[q_id][doc_id]
                )
    doc_id = "2843747"
    rank = r1.get_rank(q_id=q_id, doc_id=doc_id)
    print("Query: ", q_id)
    print("Document ", doc_id, "is ranked: ", rank)
    print("Last query: ", r1[q_id])

    return Ranking(run = results, name=name, sort=sort, copy=False)
