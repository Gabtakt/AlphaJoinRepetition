SELECT MIN(mi.info) AS movie_budget,
       MIN(mi_idx.info) AS movie_votes,
       MIN(t.title) AS movie_title
FROM cast_info AS ci,
     info_type AS it1,
     info_type AS it,
     movie_info AS mi,
     movie_info_idx AS mi_idx,
     name AS n,
     title AS t
WHERE ci.note IN ('(producer)',
                  '(executive producer)')
  AND it1.info = 'budget'
  AND it.info = 'votes'
  AND n.gender = 'm'
  AND n.name LIKE '%Tim%'
  AND t.id = mi.movie_id
  AND t.id = mi_idx.movie_id
  AND t.id = ci.movie_id
  AND ci.movie_id = mi.movie_id
  AND ci.movie_id = mi_idx.movie_id
  AND mi.movie_id = mi_idx.movie_id
  AND n.id = ci.person_id
  AND it1.id = mi.info_type_id
  AND it.id = mi_idx.info_type_id;


Aggregate  (cost=116163.51..116163.52 rows=1 width=96)
  ->  Nested Loop  (cost=1006.71..116163.50 rows=1 width=65)
        ->  Gather  (cost=1006.28..116163.04 rows=1 width=60)
              Workers Planned: 2
              ->  Nested Loop  (cost=6.28..115162.94 rows=1 width=60)
                    ->  Nested Loop  (cost=5.85..112898.01 rows=3865 width=64)
                          ->  Hash Join  (cost=5.29..75361.27 rows=1555 width=56)
                                Hash Cond: (mi.info_type_id = it1.id)
                                ->  Nested Loop  (cost=2.86..74880.43 rows=175663 width=60)
                                      ->  Hash Join  (cost=2.43..15253.60 rows=5089 width=9)
                                            Hash Cond: (mi_idx.info_type_id = it.id)
                                            ->  Parallel Seq Scan on movie_info_idx mi_idx  (cost=0.00..13685.15 rows=575015 width=13)
                                            ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                                  ->  Seq Scan on info_type it  (cost=0.00..2.41 rows=1 width=4)
                                                        Filter: ((info)::text = 'votes'::text)
                                      ->  Index Scan using movie_id_movie_info on movie_info mi  (cost=0.43..11.29 rows=43 width=51)
                                            Index Cond: (movie_id = mi_idx.movie_id)
                                ->  Hash  (cost=2.41..2.41 rows=1 width=4)
                                      ->  Seq Scan on info_type it1  (cost=0.00..2.41 rows=1 width=4)
                                            Filter: ((info)::text = 'budget'::text)
                          ->  Index Scan using movie_id_cast_info on cast_info ci  (cost=0.56..24.12 rows=2 width=8)
                                Index Cond: (movie_id = mi.movie_id)
                                Filter: ((note)::text = ANY ('{(producer),"(executive producer)"}'::text[]))
                    ->  Index Scan using name_pkey on name n  (cost=0.43..0.59 rows=1 width=4)
                          Index Cond: (id = ci.person_id)
                          Filter: (((name)::text ~~ '%Tim%'::text) AND ((gender)::text = 'm'::text))
        ->  Index Scan using title_pkey on title t  (cost=0.43..0.46 rows=1 width=21)
              Index Cond: (id = mi.movie_id)
