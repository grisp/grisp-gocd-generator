-module(generate_pipelines_grisp_software).
-export([get_template_data/0,
        transform_dep/1]).
-import(generate_pipelines, [all_otp_versions/0, default_otp_version/0, all_material_types/0]).

get_template_data() ->
    Permutations = generate_pipelines:get_permutations(config()),
    io:fwrite("Perms: ~p~n", [Permutations]),
    Graph = generate_pipelines:build_dep_graph(Permutations),
    Graph = generate_pipelines:vertex_map(fun (PipelineConfig, _Graph, _Vertex) ->
                                                  generate_pipelines:resolve_funs(PipelineConfig)
                                          end, Graph),
    generate_pipelines:vertex_map(fun
                                      (PipelineConfig, InGraph, Vertex) ->
                                         generate_pipelines:acc_template_data(
                                           PipelineConfig, InGraph, Vertex, fun generate_pipelines_grisp_software:transform_dep/1)
                                 end, Graph),
    generate_pipelines:graph_to_list(Graph).

config() ->
    [
     {grisp_software, [
                      {grisp_software, {trigger, all_material_types()}},
                      {name, fun (TList) ->
                                     Map = maps:from_list(TList),
                                     {trigger, GrispSoftware} = maps:get(grisp_software, Map),
                                     "grisp-software-" ++ atom_to_list(GrispSoftware)
                             end},
                      {group, grisp_software}
                      ]
     }
    ].

transform_dep({grisp_software, {trigger, master}}) ->
    {gitmaterial, [
                   {url, "https://github.com/grisp/grisp-software.git"},
                   {destination, "grisp-software/"},
                   {name, "grisp-software"}
                  ]};
transform_dep({grisp_software, {trigger, pr}}) ->
    {scmmaterial, [
                   {id, "b3eb61fa-d5bb-4d4a-97e2-4c2788f9ebc1"},
                   {destination, "grisp-software/"},
                   {name, "grisp-software"}
                  ]};
transform_dep({grisp_software, {trigger, fb}}) ->
    {scmmaterial, [
                   {id, "adaf123-e100-4e52-8ebf-a21193f47bf1"},
                   {destination, "grisp-software/"},
                   {name, "grisp-software"}
                  ]};
transform_dep({Key, true}) -> {Key, true};
transform_dep({Key, false}) -> {Key, false};
transform_dep({Key, Val}) when is_atom(Val) -> {Key, list_to_binary(atom_to_list(Val))};
transform_dep(Else) -> Else.
