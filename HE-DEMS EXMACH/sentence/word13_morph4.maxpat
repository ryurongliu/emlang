{
  "patcher": {
    "fileversion": 1,
    "appversion": {
      "major": 8,
      "minor": 1,
      "revision": 11,
      "architecture": "x64",
      "modernui": 1
    },
    "classnamespace": "box",
    "rect": [
      34.0,
      87.0,
      1372.0,
      779.0
    ],
    "bglocked": 0,
    "openinpresentation": 0,
    "default_fontsize": 12.0,
    "default_fontface": 0,
    "default_fontname": "Arial",
    "gridonopen": 1,
    "gridsize": [
      15.0,
      15.0
    ],
    "gridsnaponopen": 1,
    "objectsnaponopen": 1,
    "statusbarvisible": 2,
    "toolbarvisible": 1,
    "lefttoolbarpinned": 0,
    "toptoolbarpinned": 0,
    "righttoolbarpinned": 0,
    "bottomtoolbarpinned": 0,
    "toolbars_unpinned_last_save": 0,
    "tallnewobj": 0,
    "boxanimatetime": 200,
    "enablehscroll": 1,
    "enablevscroll": 1,
    "devicewidth": 0.0,
    "description": "",
    "digest": "",
    "tags": "",
    "style": "",
    "subpatcher_template": "",
    "assistshowspatchername": 0,
    "boxes": [
      {
        "box": {
          "comment": "",
          "id": "obj-1",
          "index": 0,
          "maxclass": "inlet",
          "numinlets": 0,
          "numoutlets": 1,
          "outlettype": [
            ""
          ],
          "patching_rect": [
            80.0,
            80.0,
            30.0,
            30.0
          ],
          "text": "inlet"
        }
      },
      {
        "box": {
          "comment": "",
          "id": "obj-2",
          "index": 0,
          "maxclass": "outlet",
          "numinlets": 1,
          "numoutlets": 0,
          "patching_rect": [
            160.0,
            80.0,
            30.0,
            30.0
          ],
          "text": "outlet"
        }
      },
      {
        "box": {
          "id": "obj-3",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            240.0,
            80.0
          ],
          "text": "up",
          "outlettype": [
            ""
          ]
        }
      },
      {
        "box": {
          "id": "obj-4",
          "maxclass": "newobj",
          "numinlets": 4,
          "numoutlets": 1,
          "outlettype": [
            "signal"
          ],
          "patching_rect": [
            320.0,
            80.0,
            46.0,
            22.0
          ],
          "text": "reson~ 25.0 862.6906570008321 230.0"
        }
      },
      {
        "box": {
          "id": "obj-5",
          "maxclass": "newobj",
          "numinlets": 1,
          "numoutlets": 1,
          "patching_rect": [
            400.0,
            80.0
          ],
          "text": "up",
          "outlettype": [
            ""
          ]
        }
      },
      {
        "box": {
          "id": "obj-6",
          "maxclass": "newobj",
          "numinlets": 4,
          "numoutlets": 1,
          "outlettype": [
            "signal"
          ],
          "patching_rect": [
            480.0,
            80.0,
            46.0,
            22.0
          ],
          "text": "reson~ 25.0 1018.118903571457 230.0"
        }
      },
      {
        "box": {
          "id": "obj-7",
          "maxclass": "newobj",
          "numinlets": 2,
          "numoutlets": 1,
          "outlettype": [
            "bang"
          ],
          "patching_rect": [
            560.0,
            80.0,
            37.0,
            22.0
          ],
          "text": "delay 100"
        }
      }
    ],
    "lines": [
      {
        "patchline": {
          "destination": [
            "obj-3",
            0
          ],
          "source": [
            "obj-1",
            0
          ],
          "midpoints": [
            null
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-7",
            0
          ],
          "source": [
            "obj-1",
            0
          ],
          "midpoints": [
            null
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-4",
            0
          ],
          "source": [
            "obj-3",
            0
          ],
          "midpoints": [
            null
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-2",
            0
          ],
          "source": [
            "obj-4",
            0
          ],
          "midpoints": [
            null
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-6",
            0
          ],
          "source": [
            "obj-5",
            0
          ],
          "midpoints": [
            null
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-2",
            0
          ],
          "source": [
            "obj-6",
            0
          ],
          "midpoints": [
            null
          ]
        }
      },
      {
        "patchline": {
          "destination": [
            "obj-5",
            0
          ],
          "source": [
            "obj-7",
            0
          ],
          "midpoints": [
            null
          ]
        }
      }
    ],
    "dependency_cache": [],
    "autosave": 0
  }
}