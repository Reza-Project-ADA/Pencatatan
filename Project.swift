import ProjectDescription

let project = Project(
    name: "Pencatatan",
    targets: [
        .target(
            name: "Pencatatan",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Pencatatan",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Pencatatan/Sources/**"],
            resources: ["Pencatatan/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "PencatatanTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.PencatatanTests",
            infoPlist: .default,
            sources: ["Pencatatan/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Pencatatan")]
        ),
    ]
)
