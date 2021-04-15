SELECT MIN(chn.name) AS character,
       MIN(t.title) AS movie_with_american_producer
FROM char_name AS chn,
     cast_info AS ci,
     company_name AS cn,
     company_type AS ct,
     movie_companies AS mc,
     role_type AS rt,
     title AS t
WHERE ci.note LIKE '%(producer)%'
  AND cn.country_code = '[us]'
  AND t.production_year > 1990
  AND t.id = mc.movie_id
  AND t.id = ci.movie_id
  AND ci.movie_id = mc.movie_id
  AND chn.id = ci.person_role_id
  AND rt.id = ci.role_id
  AND cn.id = mc.company_id
  AND ct.id = mc.company_type_id;


Finalize Aggregate  (cost=652926.89..652926.90 rows=1 width=64)
  ->  Gather  (cost=652926.67..652926.88 rows=2 width=64)
        Workers Planned: 2
        ->  Partial Aggregate  (cost=651926.67..651926.68 rows=1 width=64)
              ->  Hash Join  (cost=186259.66..650947.82 rows=195769 width=33)
                    Hash Cond: (ci.role_id = rt.id)
                    ->  Hash Join  (cost=186258.39..650251.17 rows=195769 width=37)
                          Hash Cond: (mc.company_type_id = ct.id)
                          ->  Parallel Hash Join  (cost=186257.30..649191.70 rows=195769 width=41)
                                Hash Cond: (ci.movie_id = t.id)
                                ->  Parallel Hash Join  (cost=73555.68..529937.15 rows=283344 width=24)
                                      Hash Cond: (ci.person_role_id = chn.id)
                                      ->  Parallel Seq Scan on cast_info ci  (cost=0.00..441459.62 rows=585462 width=12)
                                            Filter: ((note)::text ~~ '%(producer)%'::text)
                                      ->  Parallel Hash  (cost=49532.75..49532.75 rows=1308475 width=20)
                                            ->  Parallel Seq Scan on char_name chn  (cost=0.00..49532.75 rows=1308475 width=20)
                                ->  Parallel Hash  (cost=107432.22..107432.22 rows=272512 width=29)
                                      ->  Parallel Hash Join  (cost=44355.46..107432.22 rows=272512 width=29)
                                            Hash Cond: (t.id = mc.movie_id)
                                            ->  Parallel Seq Scan on title t  (cost=0.00..49166.29 rows=725867 width=21)
                                                  Filter: (production_year > 1990)
                                            ->  Parallel Hash  (cost=37866.69..37866.69 rows=395501 width=8)
                                                  ->  Parallel Hash Join  (cost=5351.53..37866.69 rows=395501 width=8)
                                                        Hash Cond: (mc.company_id = cn.id)
                                                        ->  Parallel Seq Scan on movie_companies mc  (cost=0.00..29661.37 rows=1087137 width=12)
                                                        ->  Parallel Hash  (cost=4722.92..4722.92 rows=50289 width=4)
                                                              ->  Parallel Seq Scan on company_name cn  (cost=0.00..4722.92 rows=50289 width=4)
                                                                    Filter: ((country_code)::text = '[us]'::text)
                          ->  Hash  (cost=1.04..1.04 rows=4 width=4)
                                ->  Seq Scan on company_type ct  (cost=0.00..1.04 rows=4 width=4)
                    ->  Hash  (cost=1.12..1.12 rows=12 width=4)
                          ->  Seq Scan on role_type rt  (cost=0.00..1.12 rows=12 width=4)
