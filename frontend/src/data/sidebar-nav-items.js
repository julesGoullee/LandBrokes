export default function() {
  return [
    {
      title: "Overview",
      to: "/blog-overview",
      htmlBefore: '<i class="material-icons">edit</i>',
      htmlAfter: ""
    },
    {
      title: "Credit",
      htmlBefore: '<i class="material-icons">vertical_split</i>',
      to: "/tables",
    },
    {
      title: "Profile",
      htmlBefore: '<i class="material-icons">person</i>',
      to: "/user-profile-lite",
    }
  ];
}
