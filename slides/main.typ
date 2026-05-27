#import "@preview/typslides:1.3.2": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import fletcher.shapes: diamond, hexagon, house

// Project configuration
#let mycol = rgb("#b20c0f")
#show: typslides.with(
  ratio: "16-9",
  theme: mycol,
  font: "Fira Sans",
  font-size: 20pt,
  link-style: "color",
  show-progress: true,
  back-color: rgb("#fff"),
)

#let boldvec(x) = math.bold(math.upright(x))

#let footer(content) = place(bottom, [
  #set text(size: 12pt)
  #set align(top)
  #line(length: 100%, stroke: mycol)
  #v(-0.2cm)
  #content
])

#let blob(pos, label, tint: white, ..args) = node(
  pos,
  align(center, label),
  width: 48mm,
  fill: tint.lighten(60%),
  stroke: 1pt + tint.darken(20%),
  corner-radius: 5pt,
  ..args,
)

#front-slide(
  title: [
    Generative Artificial Intelligence\
    for Chemistry
  ],
  subtitle: [Hands-on session],
  authors: [
    Philipp Leclercq
    #place(right, dy: -2cm, [
      #image("logo/unipd.svg", height: 6cm)
    ])
  ],
)

// #table-of-contents()

#slide(title: "Motivation")[
  #cols(columns: (1fr, 1fr))[
    #grayed[
      Forward design

      #diagram(
        spacing: 8pt,
        cell-size: (64mm, 24mm),
        edge-stroke: 1pt,
        edge-corner-radius: 5pt,
        mark-scale: 70%,

        blob((0, 0), [Candidate molecules], tint: blue),
        edge("-|>"),
        blob((0, 1), [Screening], tint: orange),
        edge("-|>"),
        blob((0, 2), [New compound], tint: green),
        edge((0, 1), (0.5, 1), (0.5, 0), (0, 0), "-|>")
      )
    ]
  ][
    #grayed[
      Inverse design

      #diagram(
        spacing: 8pt,
        cell-size: (64mm, 24mm),
        edge-stroke: 1pt,
        edge-corner-radius: 5pt,
        mark-scale: 70%,

        blob((0, 0), [Target properties], tint: blue),
        edge("-|>"),
        blob((0, 1), [Generative model], tint: orange),
        edge("-|>"),
        blob((0, 2), [New compound], tint: green),
      )
    ]
  ]
]

#slide(title: "Deep learning / Neural networks")[
  #cols(columns: (1fr, 1fr))[
    - Allows models to learn complex intermediate representations
    - Can fit arbitrary functions
    - Gradient-based optimization
    - For generative models:
      - What input and output?
      - How to define loss function?\
        \/ What to optimize for?
  ][
    #align(center)[
      #image("images/mlp.pdf")
      #grayed[
        $boldvec(x)^((n)) =
        f(boldvec(W)^((n))boldvec(x)^((n-1)) + boldvec(b)^((n)))$
      ]
    ]
  ]
]

#slide(title: "Molecular representations")[
  - Text-based, graph-structures or 3D coordinate based
  - Commonly: #stress("S")implified #stress("M")olecular #stress("I")nput #stress("L")ine #stress("E")ntry #stress("S")ystem
    - Ethanol: `CCO`, `OCC`, `C(C)O`, ...
    - Phenol: `c1ccccc1O`, ...
    - Canonical (i.e. deterministic) SMILES possible
    - Augmentation: Include different SMILES for same molecule in training
]


#slide(title: "Text encoding")[
  #cols(columns: (1fr, 1fr))[
    - Define token vocabulary (e.g. `C`, `N`, `O`, ...)
    - Tokenization (e.g. CCO $arrow$ [38, 38, 37])
    - Input: Map each token to a vector
    - Output: Probability for each token
  ][
    #grayed(text-size: 20pt)[
      $"softmax"(boldvec(x)_i) = exp(boldvec(x)_i)/(sum exp(boldvec(x)_j))$

      $cal(L)_"NLL" = - sum_(i=1)^N log("softmax"(boldvec(x)_(i,c_i)))$
    ]
  ]
]

#slide(title: "Recurrent neural networks (RNNs)")[
  #cols(columns: (6fr, 3fr))[
    #stress("Summarizing")
    - Input tokens fed one at a time
    - Final hidden state serves as summary
    - Can be bidirectional
    #sym.arrow Downstream regression / classification / ...

    #stress("Generation")
    - First input is start-of-sequence token
    - Predict next token probabilities based on $boldvec(h)$
    - Newly decoded token is used as next input
      - In training: teacher-forcing
    - Conditioning
      - Initial hidden state
      - Part of inputs
  ][
    #grayed(
      diagram(
        spacing: 8pt,
        cell-size: (12mm, 12mm),
        edge-stroke: 1pt,
        edge-corner-radius: 5pt,
        mark-scale: 70%,

        blob((0, 0), [Input], tint: green, width: 36mm),
        edge((0, 0), (0, 2), "-|>"),
        blob((1, 0), [$boldvec(h)_0$], tint: blue, width: 36mm),
        edge((1, 0), (1, 2), "-|>"),
        blob((0.5, 2), [RNN], tint: gray, width: 48mm),
        edge("-|>"),
        blob((0.5, 4), [$boldvec(h)_(n+1)$], tint: yellow, width: 48mm),
        edge((0.5, 4), (1.5, 4), (1.5, 1), (1, 1), "-|>"),
        edge("-|>"),
        blob((0.5, 6), [Output layer], tint: orange, width: 48mm),
      ),
    )
  ]
]

#slide(title: "Transformers")[
  #cols(columns: (1fr, 1fr))[
    #v(-2cm)
    - Process sequences in parallel
    - Attention mechanisms handle context
    - Requires positional encoding
  ][
    #v(-2cm)
    #align(center)[
      #image("images/luu.pdf", height: 13cm)
    ]
  ]
  #footer[
    Luu, R. K.; Wysokowski, M.; Buehler, M. J. Generative Discovery of de Novo Chemical Designs Using Diffusion Modeling and Transformer Deep Neural Networks with Application to Deep Eutectic Solvents. Appl. Phys. Lett. 2023, 122 (23), 234103. https://doi.org/10.1063/5.0155890.
  ]
]

#slide(title: "Validity of generated molecules")[
  - Generated SMILES may not be valid
    - Erroneous parentheses: `CC(=OC`, `CC=O)C`
    - Unclosed rings: `c1cccccO`
    - Impossible valence: `CC(=O)(C)C`
  - Explicitly incorporate syntax / validity rules
  - Self-referencing Embedded Strings (SELFIES)
    - Guaranteed validity
]

#slide(title: "Generative Adversarial Networks")[
  #align(center)[
    #image("images/GAN.png")
  #cols(columns: (1fr, 1fr))[
    Maximize "realness"
  ][
    Maximize classification accuracy
  ]
  ]
  #footer[
    Bilodeau, C.; Jin, W.; Jaakkola, T.; Barzilay, R.; Jensen, K. F. Generative Models for Molecular Discovery: Recent Advances and Challenges. WIREs Comput. Mol. Sci. 2022, 12 (5), e1608. https://doi.org/10.1002/wcms.1608.
  ]
]

#slide(title: "Variational autoencoder")[
  #align(center+top)[
    #cols(columns: (3fr, 1fr))[
      #image("images/gomez_vae.png", height: 8cm)
      #block(
        fill: rgb("#F3F2F0"),
        inset: (x: .8cm, y: .8cm),
        breakable: false,
        above: .9cm,
        below: .9cm,
        radius: (top: .2cm, bottom: .2cm),
      )[
          $cal(L) = cal(L)_"rec" + cal(L)_"pred" + beta D_"KL" + dots.h.c$
          #h(5cm)
          $boldvec(z) ~ cal(N)(0, 1)$
      ]
    ][
      #set text(size: 16pt)
      #block(
        fill: rgb("#F3F2F0"),
        inset: (x: .5cm, y: .5cm),
        breakable: false,
        radius: (top: .2cm, bottom: .2cm),
      )[
        #diagram(
          spacing: 8pt,
          cell-size: (64mm, 18mm),
          edge-stroke: 1pt,
          edge-corner-radius: 5pt,
          mark-scale: 70%,

          blob((0, 0), [Initial population], tint: green),
          edge("-|>"),
          blob((0, 1), [Add pairwise interpolations], tint: blue),
          edge("-|>"),
          blob((0, 2), [Add noise from $cal(N)(0, 0.5)$], tint: blue),
          edge("-|>"),
          blob((0, 3), [Evaluate target property], tint: blue),
          edge("-|>"),
          blob((0, 4), [Keep top $k$], tint: orange),
          edge((0, 4), (0.5, 4), (0.5, 1), (0, 1), "-|>")
        )
      ]
    ]
  ]
  #footer[
    Gómez-Bombarelli, R.; Wei, J. N.; Duvenaud, D.; Hernández-Lobato, J. M.; Sánchez-Lengeling, B.; Sheberla, D.; Aguilera-Iparraguirre, J.; Hirzel, T. D.; Adams, R. P.; Aspuru-Guzik, A. Automatic Chemical Design Using a Data-Driven Continuous Representation of Molecules. ACS Cent. Sci. 2018, 4 (2), 268–276. https://doi.org/10.1021/acscentsci.7b00572.
  ]
]

#slide(title: "See also")[
  - Diffusion
  - Normalizing flow
  - Evolutionary algorithms
  - Reinforcement learning
]
