defmodule Webserver.HTML do
  @doc ~s"""
  Prints a HTML tree as a list suitable for 'IO'.

  Tree is most generically built out of triples `{:tag, attributes, children}`. 
  Where:

  * `attributes` is a keword list
  * `children` is a list of nodes or a string

  Both `attributes` and `children` can be ommitted. 

  ## Examples

      iex> List.to_string print({:div})
      "<div />"

      iex> List.to_string print({:p, "hello!"})
      "<p>hello!</p>"

      iex> List.to_string print({:img, [src: "foo.png"]})
      "<img src=\\"foo.png\\" />"

      iex> List.to_string print({:p, [class: "my-class"], "hello!"})
      "<p class=\\"my-class\\">hello!</p>"

      iex> List.to_string print({:p, [class: "my-class"], ["hello! ", {:em, "Emphasis"} ," and more"]})
      "<p class=\\"my-class\\">\\n  hello! \\n  <em>Emphasis</em>\\n   and more\\n</p>"

      iex> List.to_string print({:div, [class: "foo"], [{:p, "hello"}]})
      "<div class=\\"foo\\">\\n  <p>hello</p>\\n</div>"

      iex> List.to_string print({:div, [class: "foo"], {:p, "hello"}})
      "<div class=\\"foo\\">\\n  <p>hello</p>\\n</div>"

      iex> List.to_string print({:div, [], [
      ...>   {:p, "hello"}, {:p, "goodbye"}
      ...> ]})
      "<div>\\n  <p>hello</p>\\n  <p>goodbye</p>\\n</div>"

      iex> List.to_string print({:div, [class: "foo"], [
      ...>   {:article, [class: "item"], [
      ...>     {:p, "hello"}, {:p, "goodbye"}
      ...>   ]}
      ...> ]})
      "<div class=\\"foo\\">\\n  <article class=\\"item\\">\\n    <p>hello</p>\\n    <p>goodbye</p>\\n  </article>\\n</div>"
     
  """
  def print(node)

  def print(node, indent \\ 0)

  def print(node, indent) when is_binary(node) do
    [indent(indent), node]
  end

  def print({name}, indent) when is_atom(name) do
    [indent(indent), "<#{name} />"]
  end

  def print({name, content}, indent) when is_atom(name) and is_binary(content) do
    [indent(indent), "<#{name}>", content, "</#{name}>"]
  end

  def print({name, attributes}, indent) when is_atom(name) and is_list(attributes) do
    space = if length(attributes) < 1, do: "", else: " "

    [indent(indent), "<#{name}", space, print_attributes(attributes), " />"]
  end

  def print({name, attributes, content}, indent)
      when is_atom(name) and is_list(attributes) and is_binary(content) do
    [indent(indent), "<#{name} ", print_attributes(attributes), ">", content, "</#{name}>"]
  end

  def print({name, attributes, child}, indent)
      when is_atom(name) and is_list(attributes) and is_tuple(child) do
    print({name, attributes, [child]}, indent)
  end

  def print({name, attributes, children}, indent)
      when is_atom(name) and is_list(attributes) and is_list(children) do
    space = if length(attributes) < 1, do: "", else: " "
    content = Enum.map(children, fn c -> print(c, indent + 1) end)

    # TODO print children starting with text inline (well need a wrap and no-wrap mode)

    [
      indent(indent),
      "<#{name}",
      space,
      print_attributes(attributes),
      ">\n",
      Enum.intersperse(content, "\n"),
      "\n",
      indent(indent),
      "</#{name}>"
    ]
  end

  # Private helpers

  defp print_attributes(attrs) do
    Enum.map(attrs, &print_attr/1) |> Enum.intersperse(" ")
  end

  defp print_attr({k, v}) when is_atom(k) and is_binary(v) do
    [to_string(k), "=\"", v, "\""]
  end

  defp print_attr(_attr) do
    ""
  end

  defp indent(depth) do
    String.duplicate("  ", depth)
  end

  defmodule DOM do
    @tags [
      :a,
      :abbr,
      :acronym,
      :address,
      :applet,
      :area,
      :article,
      :aside,
      :audio,
      :b,
      :base,
      :basefont,
      :bdi,
      :bdo,
      :bgsound,
      :big,
      :blink,
      :blockquote,
      :body,
      :br,
      :button,
      :canvas,
      :caption,
      :center,
      :cite,
      :code,
      :col,
      :colgroup,
      :command,
      :content,
      :data,
      :datalist,
      :dd,
      :del,
      :details,
      :dfn,
      :dialog,
      :dir,
      :div,
      :dl,
      :dt,
      :element,
      :em,
      :embed,
      :fieldset,
      :figcaption,
      :figure,
      :font,
      :footer,
      :form,
      :frame,
      :frameset,
      :h1,
      :head,
      :header,
      :hgroup,
      :hr,
      :html,
      :i,
      :iframe,
      :image,
      :img,
      :input,
      :ins,
      :isindex,
      :kbd,
      :keygen,
      :label,
      :legend,
      :li,
      :link,
      :listing,
      :main,
      :map,
      :mark,
      :marquee,
      :menu,
      :menuitem,
      :meta,
      :meter,
      :multicol,
      :nav,
      :nextid,
      :nobr,
      :noembed,
      :noframes,
      :noscript,
      :object,
      :ol,
      :optgroup,
      :option,
      :output,
      :p,
      :param,
      :picture,
      :plaintext,
      :pre,
      :progress,
      :q,
      :rb,
      :rp,
      :rt,
      :rtc,
      :ruby,
      :s,
      :samp,
      :script,
      :section,
      :select,
      :shadow,
      :slot,
      :small,
      :source,
      :spacer,
      :span,
      :strike,
      :strong,
      :style,
      :sub,
      :summary,
      :sup,
      :table,
      :tbody,
      :td,
      :template,
      :textarea,
      :tfoot,
      :th,
      :thead,
      :time,
      :title,
      :tr,
      :track,
      :tt,
      :u,
      :ul,
      :var,
      :video,
      :wbr,
      :xmp
    ]

    @tags
    |> Enum.each(fn name ->
      def unquote(name)() do
        {unquote(name)}
      end

      def unquote(name)(a) do
        {unquote(name), a}
      end

      def unquote(name)(a, b) do
        {unquote(name), a, b}
      end
    end)
  end
end
