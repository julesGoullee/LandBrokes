export default function() {
  return [
    {
      title: "Overview",
      to: "/blog-overview",
      htmlBefore: '<i class="material-icons">grid_on</i>',
      htmlAfter: ""
    },
    {
      title: "Credit",
      htmlBefore: '<i class="material-icons">credit_card</i>',
      to: "/tables",
    },
    {
      title: "Profile",
      htmlBefore: '<i class="material-icons">person</i>',
      to: "/user-profile-lite",
    }
  ];
}
