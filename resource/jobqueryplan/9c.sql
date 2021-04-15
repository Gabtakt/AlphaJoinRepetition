SELECT MIN(an.name) AS alternative_name,
       MIN(chn.name) AS voiced_character_name,
       MIN(n.name) AS voicing_actress,
       MIN(t.title) AS american_movie
FROM aka_name AS an,
     char_name AS chn,
     cast_info AS ci,
     company_name AS cn,
     movie_companies AS mc,
     name AS n,
     role_type AS rt,
     title AS t
WHERE ci.note IN ('(voice)',
                  '(voice: Japanese version)',
                  '(voice) (uncredited)',
                  '(voice: English version)')
  AND cn.country_code = '[us]'
  AND n.gender = 'f'
  AND n.name LIKE '%An%'
  AND rt.role = 'actress'
  AND ci.movie_id = t.id
  AND t.id = mc.movie_id
  AND ci.movie_id = mc.movie_id
  AND mc.company_id = cn.id
  AND ci.role_id = rt.id
  AND n.id = ci.person_id
  AND chn.id = ci.person_role_id
  AND an.person_id = n.id
  AND an.person_id = ci.person_id;



Finalize Aggregate  (cost=147664.17..147664.18 rows=1 width=128)
  ->  Gather  (cost=147663.94..147664.15 rows=2 width=128)
        Workers Planned: 2
        ->  Partial Aggregate  (cost=146663.94..146663.95 rows=1 width=128)
              ->  Nested Loop  (cost=81861.81..146660.87 rows=307 width=64)
                    Join Filter: (ci.movie_id = t.id)
                    ->  Nested Loop  (cost=81861.38..146499.44 rows=307 width=55)
                          ->  Nested Loop  (cost=81860.96..146124.26 rows=842 width=59)
                                ->  Nested Loop  (cost=81860.53..145913.41 rows=306 width=51)
                                      ->  Hash Join  (cost=81860.10..145497.22 rows=632 width=39)
                                            Hash Cond: (ci.role_id = rt.id)
                                            ->  Nested Loop  (cost=81858.93..145469.14 rows=7578 width=43)
                                                  Join Filter: (n.id = ci.person_id)
                                                  ->  Parallel Hash Join  (cost=81858.37..97995.81 rows=3435 width=39)
                                                        Hash Cond: (an.person_id = n.id)
                                                        ->  Parallel Seq Scan on aka_name an  (cost=0.00..15151.60 rows=375560 width=20)
                                                        ->  Parallel Hash  (cost=81659.82..81659.82 rows=15884 width=19)
                                                              ->  Parallel Seq Scan on name n  (cost=0.00..81659.82 rows=15884 width=19)
                                                                    Filter: (((name)::text ~~ '%An%'::text) AND ((gender)::text = 'f'::text))
                                                  ->  Index Scan using person_id_cast_info on cast_info ci  (cost=0.56..13.67 rows=12 width=16)
                                                        Index Cond: (person_id = an.person_id)
                                                        Filter: ((note)::text = ANY ('{(voice),"(voice: Japanese version)","(voice) (uncredited)","(voice: English version)"}'::text[]))
                                            ->  Hash  (cost=1.15..1.15 rows=1 width=4)
                                                  ->  Seq Scan on role_type rt  (cost=0.00..1.15 rows=1 width=4)
                                                        Filter: ((role)::text = 'actress'::text)
                                      ->  Index Scan using char_name_pkey on char_name chn  (cost=0.43..0.66 rows=1 width=20)
                                            Index Cond: (id = ci.person_role_id)
                                ->  Index Scan using movie_id_movie_companies on movie_companies mc  (cost=0.43..0.64 rows=5 width=8)
                                      Index Cond: (movie_id = ci.movie_id)
                          ->  Index Scan using company_name_pkey on company_name cn  (cost=0.42..0.45 rows=1 width=4)
                                Index Cond: (id = mc.company_id)
                                Filter: ((country_code)::text = '[us]'::text)
                    ->  Index Scan using title_pkey on title t  (cost=0.43..0.51 rows=1 width=21)
                          Index Cond: (id = mc.movie_id)
